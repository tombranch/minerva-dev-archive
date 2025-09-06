#!/bin/bash

# Comprehensive Health Check Script
# Monitor application health across all environments

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Configuration
TIMEOUT=30
HEALTH_REPORT="health-check-$(date +%Y%m%d_%H%M%S).json"
WATCH_MODE=false
WATCH_INTERVAL=60

# Health check results
declare -A HEALTH_RESULTS

# Initialize health report
init_health_report() {
    cat > "$HEALTH_REPORT" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "environment": "$ENVIRONMENT",
  "base_url": "$BASE_URL",
  "checks": {}
}
EOF
}

# Update health report
update_health_report() {
    local check_name=$1
    local status=$2
    local details=$3
    local response_time=${4:-0}
    
    local temp_file=$(mktemp)
    jq ".checks[\"$check_name\"] = {
        \"status\": \"$status\",
        \"details\": \"$details\",
        \"response_time_ms\": $response_time,
        \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
    }" "$HEALTH_REPORT" > "$temp_file"
    mv "$temp_file" "$HEALTH_REPORT"
}

# HTTP request with timing
timed_http_request() {
    local url=$1
    local method=${2:-"GET"}
    local expected_status=${3:-200}
    local headers=${4:-""}
    
    local start_time=$(date +%s%N)
    local response
    local http_code
    local response_time
    
    if [[ -n "$headers" ]]; then
        response=$(curl -s -w '%{http_code}' --max-time $TIMEOUT -H "$headers" -X "$method" "$url" 2>/dev/null || echo "000")
    else
        response=$(curl -s -w '%{http_code}' --max-time $TIMEOUT -X "$method" "$url" 2>/dev/null || echo "000")
    fi
    
    local end_time=$(date +%s%N)
    response_time=$(( (end_time - start_time) / 1000000 ))
    
    http_code="${response: -3}"
    local body="${response%???}"
    
    if [[ "$http_code" == "$expected_status" ]]; then
        echo "$body"
        export HTTP_RESPONSE_TIME=$response_time
        return 0
    else
        export HTTP_RESPONSE_TIME=$response_time
        export HTTP_ERROR_CODE=$http_code
        return 1
    fi
}

# Check basic connectivity
check_connectivity() {
    log "Checking basic connectivity..."
    
    local response
    if response=$(timed_http_request "$BASE_URL"); then
        success "✅ Basic connectivity OK (${HTTP_RESPONSE_TIME}ms)"
        update_health_report "connectivity" "healthy" "Site reachable" "$HTTP_RESPONSE_TIME"
        HEALTH_RESULTS[connectivity]="✅"
    else
        error "❌ Basic connectivity FAILED (${HTTP_ERROR_CODE:-timeout})"
        update_health_report "connectivity" "unhealthy" "Site unreachable - HTTP ${HTTP_ERROR_CODE:-timeout}" "$HTTP_RESPONSE_TIME"
        HEALTH_RESULTS[connectivity]="❌"
    fi
}

# Check health endpoints
check_health_endpoints() {
    log "Checking health endpoints..."
    
    # Basic health
    local response
    if response=$(timed_http_request "$BASE_URL/api/health"); then
        success "✅ Basic health endpoint OK (${HTTP_RESPONSE_TIME}ms)"
        update_health_report "health_basic" "healthy" "Health endpoint responding" "$HTTP_RESPONSE_TIME"
        HEALTH_RESULTS[health_basic]="✅"
    else
        error "❌ Basic health endpoint FAILED"
        update_health_report "health_basic" "unhealthy" "Health endpoint not responding" "$HTTP_RESPONSE_TIME"
        HEALTH_RESULTS[health_basic]="❌"
    fi
    
    # Deep health check
    if response=$(timed_http_request "$BASE_URL/api/health/deep"); then
        # Parse JSON response
        local db_status=$(echo "$response" | jq -r '.checks.database // "unknown"' 2>/dev/null || echo "unknown")
        local storage_status=$(echo "$response" | jq -r '.checks.storage // "unknown"' 2>/dev/null || echo "unknown")
        local ai_status=$(echo "$response" | jq -r '.checks.ai // "unknown"' 2>/dev/null || echo "unknown")
        
        success "✅ Deep health check OK (${HTTP_RESPONSE_TIME}ms)"
        info "  Database: $db_status"
        info "  Storage: $storage_status"
        info "  AI Service: $ai_status"
        
        update_health_report "health_deep" "healthy" "DB:$db_status,Storage:$storage_status,AI:$ai_status" "$HTTP_RESPONSE_TIME"
        HEALTH_RESULTS[health_deep]="✅"
    else
        warning "⚠️ Deep health check FAILED or DEGRADED"
        update_health_report "health_deep" "degraded" "Deep health check failed" "$HTTP_RESPONSE_TIME"
        HEALTH_RESULTS[health_deep]="⚠️"
    fi
}

# Check authentication endpoints
check_auth_endpoints() {
    log "Checking authentication endpoints..."
    
    local auth_endpoints=(
        "/auth/signin:200"
        "/auth/signup:200"
        "/auth/callback:405"  # Should return method not allowed
    )
    
    local auth_healthy=true
    
    for endpoint_config in "${auth_endpoints[@]}"; do
        local endpoint=$(echo "$endpoint_config" | cut -d':' -f1)
        local expected_code=$(echo "$endpoint_config" | cut -d':' -f2)
        
        if timed_http_request "$BASE_URL$endpoint" "GET" "$expected_code" > /dev/null; then
            success "✅ Auth endpoint $endpoint OK"
        else
            error "❌ Auth endpoint $endpoint FAILED"
            auth_healthy=false
        fi
    done
    
    if [[ "$auth_healthy" == true ]]; then
        update_health_report "auth_endpoints" "healthy" "All auth endpoints responding" "0"
        HEALTH_RESULTS[auth_endpoints]="✅"
    else
        update_health_report "auth_endpoints" "unhealthy" "Some auth endpoints failing" "0"
        HEALTH_RESULTS[auth_endpoints]="❌"
    fi
}

# Check API endpoints
check_api_endpoints() {
    log "Checking API endpoints..."
    
    # Test public endpoints
    local public_endpoints=(
        "/api/health"
        "/api/health/deep"
    )
    
    local api_healthy=true
    
    for endpoint in "${public_endpoints[@]}"; do
        if timed_http_request "$BASE_URL$endpoint" > /dev/null; then
            success "✅ API endpoint $endpoint OK (${HTTP_RESPONSE_TIME}ms)"
        else
            error "❌ API endpoint $endpoint FAILED"
            api_healthy=false
        fi
    done
    
    # Test protected endpoints (should return 401/403)
    local protected_endpoints=(
        "/api/photos"
        "/api/projects"
        "/api/users/profile"
    )
    
    for endpoint in "${protected_endpoints[@]}"; do
        if timed_http_request "$BASE_URL$endpoint" "GET" "401" > /dev/null || 
           timed_http_request "$BASE_URL$endpoint" "GET" "403" > /dev/null; then
            success "✅ Protected endpoint $endpoint properly secured"
        else
            warning "⚠️ Protected endpoint $endpoint security check failed"
            # Don't mark as unhealthy for security issues
        fi
    done
    
    if [[ "$api_healthy" == true ]]; then
        update_health_report "api_endpoints" "healthy" "API endpoints responding" "0"
        HEALTH_RESULTS[api_endpoints]="✅"
    else
        update_health_report "api_endpoints" "unhealthy" "Some API endpoints failing" "0"
        HEALTH_RESULTS[api_endpoints]="❌"
    fi
}

# Check database connectivity
check_database() {
    log "Checking database connectivity..."
    
    # Try to get database status from health endpoint
    local response
    if response=$(timed_http_request "$BASE_URL/api/health/deep"); then
        local db_status=$(echo "$response" | jq -r '.checks.database.status // "unknown"' 2>/dev/null || echo "unknown")
        
        case $db_status in
            "healthy"|"ok"|"connected"|true)
                success "✅ Database connectivity OK"
                update_health_report "database" "healthy" "Database connected" "$HTTP_RESPONSE_TIME"
                HEALTH_RESULTS[database]="✅"
                ;;
            "unhealthy"|"error"|"disconnected"|false)
                error "❌ Database connectivity FAILED"
                update_health_report "database" "unhealthy" "Database connection failed" "$HTTP_RESPONSE_TIME"
                HEALTH_RESULTS[database]="❌"
                ;;
            *)
                warning "⚠️ Database status unknown: $db_status"
                update_health_report "database" "unknown" "Database status unclear: $db_status" "$HTTP_RESPONSE_TIME"
                HEALTH_RESULTS[database]="⚠️"
                ;;
        esac
    else
        error "❌ Cannot check database status"
        update_health_report "database" "unhealthy" "Unable to check database status" "$HTTP_RESPONSE_TIME"
        HEALTH_RESULTS[database]="❌"
    fi
}

# Check external services
check_external_services() {
    log "Checking external services..."
    
    # Check AI service status
    local response
    if response=$(timed_http_request "$BASE_URL/api/health/deep"); then
        local ai_status=$(echo "$response" | jq -r '.checks.ai.status // "unknown"' 2>/dev/null || echo "unknown")
        
        case $ai_status in
            "healthy"|"ok"|"available"|true)
                success "✅ AI service OK"
                update_health_report "ai_service" "healthy" "AI service available" "$HTTP_RESPONSE_TIME"
                HEALTH_RESULTS[ai_service]="✅"
                ;;
            "unhealthy"|"error"|"unavailable"|false)
                error "❌ AI service FAILED"
                update_health_report "ai_service" "unhealthy" "AI service unavailable" "$HTTP_RESPONSE_TIME"
                HEALTH_RESULTS[ai_service]="❌"
                ;;
            *)
                warning "⚠️ AI service status unknown: $ai_status"
                update_health_report "ai_service" "unknown" "AI service status unclear: $ai_status" "$HTTP_RESPONSE_TIME"
                HEALTH_RESULTS[ai_service]="⚠️"
                ;;
        esac
    else
        warning "⚠️ Cannot check AI service status"
        update_health_report "ai_service" "unknown" "Unable to check AI service status" "$HTTP_RESPONSE_TIME"
        HEALTH_RESULTS[ai_service]="⚠️"
    fi
}

# Check SSL certificate
check_ssl() {
    log "Checking SSL certificate..."
    
    if [[ "$BASE_URL" =~ ^https:// ]]; then
        local domain=$(echo "$BASE_URL" | sed 's|https://||' | sed 's|/.*||')
        
        local ssl_info
        ssl_info=$(echo | openssl s_client -connect "$domain:443" -servername "$domain" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)
        
        if [[ $? -eq 0 ]]; then
            local not_after=$(echo "$ssl_info" | grep "notAfter" | cut -d'=' -f2)
            local expiry_date=$(date -d "$not_after" +%s 2>/dev/null || echo "0")
            local current_date=$(date +%s)
            local days_until_expiry=$(( (expiry_date - current_date) / 86400 ))
            
            if [[ $days_until_expiry -gt 30 ]]; then
                success "✅ SSL certificate OK ($days_until_expiry days until expiry)"
                update_health_report "ssl_certificate" "healthy" "Valid for $days_until_expiry days" "0"
                HEALTH_RESULTS[ssl_certificate]="✅"
            elif [[ $days_until_expiry -gt 7 ]]; then
                warning "⚠️ SSL certificate expires soon ($days_until_expiry days)"
                update_health_report "ssl_certificate" "warning" "Expires in $days_until_expiry days" "0"
                HEALTH_RESULTS[ssl_certificate]="⚠️"
            else
                error "❌ SSL certificate expires very soon or is expired ($days_until_expiry days)"
                update_health_report "ssl_certificate" "critical" "Expires in $days_until_expiry days" "0"
                HEALTH_RESULTS[ssl_certificate]="❌"
            fi
        else
            error "❌ SSL certificate check FAILED"
            update_health_report "ssl_certificate" "unhealthy" "Unable to verify certificate" "0"
            HEALTH_RESULTS[ssl_certificate]="❌"
        fi
    else
        info "ℹ️ HTTP URL - SSL check skipped"
        update_health_report "ssl_certificate" "skipped" "HTTP URL provided" "0"
        HEALTH_RESULTS[ssl_certificate]="ℹ️"
    fi
}

# Check performance metrics
check_performance() {
    log "Checking performance metrics..."
    
    local total_time=0
    local requests=5
    
    for i in $(seq 1 $requests); do
        if timed_http_request "$BASE_URL" > /dev/null; then
            total_time=$((total_time + HTTP_RESPONSE_TIME))
        else
            warning "Performance test request $i failed"
        fi
        sleep 1
    done
    
    local avg_time=$((total_time / requests))
    
    if [[ $avg_time -lt 1000 ]]; then
        success "✅ Performance excellent (${avg_time}ms avg)"
        update_health_report "performance" "excellent" "Average response time ${avg_time}ms" "$avg_time"
        HEALTH_RESULTS[performance]="✅"
    elif [[ $avg_time -lt 3000 ]]; then
        success "✅ Performance good (${avg_time}ms avg)"
        update_health_report "performance" "good" "Average response time ${avg_time}ms" "$avg_time"
        HEALTH_RESULTS[performance]="✅"
    elif [[ $avg_time -lt 5000 ]]; then
        warning "⚠️ Performance acceptable (${avg_time}ms avg)"
        update_health_report "performance" "acceptable" "Average response time ${avg_time}ms" "$avg_time"
        HEALTH_RESULTS[performance]="⚠️"
    else
        error "❌ Performance poor (${avg_time}ms avg)"
        update_health_report "performance" "poor" "Average response time ${avg_time}ms" "$avg_time"
        HEALTH_RESULTS[performance]="❌"
    fi
}

# Display health summary
display_health_summary() {
    echo
    echo "================================================"
    echo "HEALTH CHECK SUMMARY - $ENVIRONMENT"
    echo "================================================"
    echo "URL: $BASE_URL"
    echo "Time: $(date)"
    echo
    
    local healthy_count=0
    local warning_count=0
    local unhealthy_count=0
    local total_count=0
    
    for check in connectivity health_basic health_deep auth_endpoints api_endpoints database ai_service ssl_certificate performance; do
        if [[ -n "${HEALTH_RESULTS[$check]}" ]]; then
            printf "%-20s %s\n" "$check:" "${HEALTH_RESULTS[$check]}"
            total_count=$((total_count + 1))
            
            case "${HEALTH_RESULTS[$check]}" in
                "✅") healthy_count=$((healthy_count + 1)) ;;
                "⚠️") warning_count=$((warning_count + 1)) ;;
                "❌") unhealthy_count=$((unhealthy_count + 1)) ;;
            esac
        fi
    done
    
    echo
    echo "Summary: $healthy_count healthy, $warning_count warnings, $unhealthy_count unhealthy"
    
    if [[ $unhealthy_count -eq 0 && $warning_count -eq 0 ]]; then
        echo "Status: 🟢 ALL SYSTEMS HEALTHY"
    elif [[ $unhealthy_count -eq 0 ]]; then
        echo "Status: 🟡 HEALTHY WITH WARNINGS"
    elif [[ $unhealthy_count -le 2 ]]; then
        echo "Status: 🟠 DEGRADED SERVICE"
    else
        echo "Status: 🔴 SERVICE UNHEALTHY"
    fi
    
    echo
    echo "Detailed report: $HEALTH_REPORT"
    echo "================================================"
}

# Continuous monitoring mode
watch_health() {
    log "Starting continuous health monitoring (${WATCH_INTERVAL}s intervals)"
    log "Press Ctrl+C to stop"
    
    while true; do
        clear
        echo "=== CONTINUOUS HEALTH MONITORING ==="
        echo "Environment: $ENVIRONMENT"
        echo "URL: $BASE_URL"
        echo "Update: $(date)"
        echo
        
        # Run health checks
        check_connectivity
        check_health_endpoints
        check_database
        check_external_services
        check_performance
        
        # Display summary
        display_health_summary
        
        sleep $WATCH_INTERVAL
    done
}

# Show usage
show_usage() {
    echo "Usage: $0 [ENVIRONMENT] [OPTIONS]"
    echo
    echo "ENVIRONMENT:"
    echo "  staging     - Check staging environment health"
    echo "  production  - Check production environment health"
    echo "  local       - Check local development environment"
    echo
    echo "OPTIONS:"
    echo "  --url URL        - Custom base URL to check"
    echo "  --watch         - Continuous monitoring mode"
    echo "  --interval SEC  - Watch mode update interval (default: 60s)"
    echo "  --timeout SEC   - Request timeout (default: 30s)"
    echo "  --json          - Output results in JSON format only"
    echo "  --help          - Show this help message"
    echo
    echo "Examples:"
    echo "  $0 production"
    echo "  $0 staging --watch"
    echo "  $0 production --url https://minerva.yourdomain.com"
    echo "  $0 staging --watch --interval 30"
}

# Main execution
main() {
    local environment=""
    local base_url=""
    local json_only=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            staging|production|local)
                environment=$1
                shift
                ;;
            --url)
                base_url=$2
                shift 2
                ;;
            --watch)
                WATCH_MODE=true
                shift
                ;;
            --interval)
                WATCH_INTERVAL=$2
                shift 2
                ;;
            --timeout)
                TIMEOUT=$2
                shift 2
                ;;
            --json)
                json_only=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate arguments
    if [[ -z "$environment" ]]; then
        error "Environment required (staging, production, or local)"
        show_usage
        exit 1
    fi
    
    # Set default URLs based on environment
    if [[ -z "$base_url" ]]; then
        case $environment in
            "staging")
                base_url="https://staging-minerva.vercel.app"
                ;;
            "production")
                base_url="https://minerva.yourdomain.com"
                ;;
            "local")
                base_url="http://localhost:3000"
                ;;
        esac
    fi
    
    ENVIRONMENT=$environment
    BASE_URL=$base_url
    
    # Initialize
    init_health_report
    
    if [[ "$json_only" == true ]]; then
        # JSON output mode - run checks silently
        exec 1>/dev/null 2>&1
    fi
    
    if [[ "$WATCH_MODE" == true ]]; then
        watch_health
    else
        log "Starting health check for $environment environment"
        log "Target URL: $BASE_URL"
        
        # Run all health checks
        check_connectivity
        check_health_endpoints
        check_auth_endpoints
        check_api_endpoints
        check_database
        check_external_services
        check_ssl
        check_performance
        
        if [[ "$json_only" == true ]]; then
            # Restore output and show only JSON
            exec 1>&2
            cat "$HEALTH_REPORT"
        else
            # Display summary
            display_health_summary
        fi
        
        # Exit with appropriate code
        local unhealthy_count=0
        for result in "${HEALTH_RESULTS[@]}"; do
            if [[ "$result" == "❌" ]]; then
                unhealthy_count=$((unhealthy_count + 1))
            fi
        done
        
        if [[ $unhealthy_count -eq 0 ]]; then
            exit 0
        elif [[ $unhealthy_count -le 2 ]]; then
            exit 1
        else
            exit 2
        fi
    fi
}

# Handle script termination
cleanup() {
    warning "Health check interrupted"
    if [[ -f "$HEALTH_REPORT" ]]; then
        log "Health report available: $HEALTH_REPORT"
    fi
    exit 1
}

trap cleanup SIGINT SIGTERM

# Run main function
main "$@"