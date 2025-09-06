#!/bin/bash

# Post-Deployment Verification Script
# Comprehensive testing after deployment to staging or production

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

# Configuration
TIMEOUT=30
RETRY_COUNT=3
REPORT_FILE="deployment-verification-$(date +%Y%m%d_%H%M%S).log"

# Test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNINGS=0

# Initialize report
init_report() {
    {
        echo "================================================"
        echo "MINERVA DEPLOYMENT VERIFICATION REPORT"
        echo "================================================"
        echo "Date: $(date)"
        echo "Environment: $ENVIRONMENT"
        echo "Base URL: $BASE_URL"
        echo "================================================"
        echo
    } > "$REPORT_FILE"
}

# Add test result to report
add_result() {
    local test_name=$1
    local status=$2
    local details=$3
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    case $status in
        "PASS")
            PASSED_TESTS=$((PASSED_TESTS + 1))
            echo "[PASS] $test_name" >> "$REPORT_FILE"
            ;;
        "FAIL")
            FAILED_TESTS=$((FAILED_TESTS + 1))
            echo "[FAIL] $test_name" >> "$REPORT_FILE"
            if [[ -n "$details" ]]; then
                echo "       Details: $details" >> "$REPORT_FILE"
            fi
            ;;
        "WARN")
            WARNINGS=$((WARNINGS + 1))
            echo "[WARN] $test_name" >> "$REPORT_FILE"
            if [[ -n "$details" ]]; then
                echo "       Details: $details" >> "$REPORT_FILE"
            fi
            ;;
    esac
    
    echo >> "$REPORT_FILE"
}

# HTTP request with retry
http_request() {
    local url=$1
    local method=${2:-"GET"}
    local expected_status=${3:-200}
    local headers=${4:-""}
    local data=${5:-""}
    local retry=0
    
    while [[ $retry -lt $RETRY_COUNT ]]; do
        local curl_cmd="curl -s -w '%{http_code}' --max-time $TIMEOUT"
        
        if [[ -n "$headers" ]]; then
            curl_cmd="$curl_cmd -H '$headers'"
        fi
        
        if [[ "$method" != "GET" ]]; then
            curl_cmd="$curl_cmd -X $method"
        fi
        
        if [[ -n "$data" ]]; then
            curl_cmd="$curl_cmd -d '$data'"
        fi
        
        curl_cmd="$curl_cmd '$url'"
        
        local response=$(eval $curl_cmd 2>/dev/null)
        local http_code="${response: -3}"
        local body="${response%???}"
        
        if [[ "$http_code" == "$expected_status" ]]; then
            echo "$body"
            return 0
        fi
        
        retry=$((retry + 1))
        if [[ $retry -lt $RETRY_COUNT ]]; then
            sleep 2
        fi
    done
    
    return 1
}

# Test 1: Basic connectivity
test_basic_connectivity() {
    log "Testing basic connectivity..."
    
    if http_request "$BASE_URL" > /dev/null; then
        success "Basic connectivity test passed"
        add_result "Basic Connectivity" "PASS"
    else
        error "Basic connectivity test failed"
        add_result "Basic Connectivity" "FAIL" "Unable to reach $BASE_URL"
        return 1
    fi
}

# Test 2: Health endpoints
test_health_endpoints() {
    log "Testing health endpoints..."
    
    # Basic health
    if http_request "$BASE_URL/api/health" > /dev/null; then
        success "Basic health endpoint responding"
        add_result "Health Endpoint - Basic" "PASS"
    else
        error "Basic health endpoint failed"
        add_result "Health Endpoint - Basic" "FAIL"
    fi
    
    # Deep health check
    local deep_health_response
    deep_health_response=$(http_request "$BASE_URL/api/health/deep")
    if [[ $? -eq 0 ]]; then
        if echo "$deep_health_response" | grep -q '"status":"healthy"'; then
            success "Deep health check passed"
            add_result "Health Endpoint - Deep" "PASS"
        else
            warning "Deep health check returned degraded status"
            add_result "Health Endpoint - Deep" "WARN" "Service degraded"
        fi
    else
        error "Deep health endpoint failed"
        add_result "Health Endpoint - Deep" "FAIL"
    fi
}

# Test 3: Authentication pages
test_auth_pages() {
    log "Testing authentication pages..."
    
    # Login page
    if http_request "$BASE_URL/auth/signin" > /dev/null; then
        success "Login page accessible"
        add_result "Authentication - Login Page" "PASS"
    else
        error "Login page not accessible"
        add_result "Authentication - Login Page" "FAIL"
    fi
    
    # Registration page
    if http_request "$BASE_URL/auth/signup" > /dev/null; then
        success "Registration page accessible"
        add_result "Authentication - Registration Page" "PASS"
    else
        error "Registration page not accessible"
        add_result "Authentication - Registration Page" "FAIL"
    fi
}

# Test 4: API endpoints
test_api_endpoints() {
    log "Testing API endpoints..."
    
    # Test public API endpoints that don't require auth
    local endpoints=(
        "/api/health"
        "/api/health/deep"
    )
    
    for endpoint in "${endpoints[@]}"; do
        if http_request "$BASE_URL$endpoint" > /dev/null; then
            success "API endpoint $endpoint responding"
            add_result "API Endpoint - $endpoint" "PASS"
        else
            error "API endpoint $endpoint failed"
            add_result "API Endpoint - $endpoint" "FAIL"
        fi
    done
    
    # Test protected endpoints (should return 401/403)
    local protected_endpoints=(
        "/api/photos"
        "/api/projects"
        "/api/users/profile"
    )
    
    for endpoint in "${protected_endpoints[@]}"; do
        if http_request "$BASE_URL$endpoint" "GET" 401 > /dev/null || 
           http_request "$BASE_URL$endpoint" "GET" 403 > /dev/null; then
            success "Protected endpoint $endpoint properly secured"
            add_result "API Security - $endpoint" "PASS"
        else
            warning "Protected endpoint $endpoint security check failed"
            add_result "API Security - $endpoint" "WARN" "Unexpected response code"
        fi
    done
}

# Test 5: Static assets
test_static_assets() {
    log "Testing static assets..."
    
    # Test common static files
    local assets=(
        "/favicon.ico"
        "/_next/static/chunks/webpack.js"
    )
    
    for asset in "${assets[@]}"; do
        if http_request "$BASE_URL$asset" > /dev/null; then
            success "Static asset $asset loading"
            add_result "Static Asset - $asset" "PASS"
        else
            warning "Static asset $asset not found"
            add_result "Static Asset - $asset" "WARN" "Asset not found or not cached yet"
        fi
    done
}

# Test 6: Performance metrics
test_performance() {
    log "Testing performance metrics..."
    
    # Measure response time for main page
    local start_time=$(date +%s%N)
    if http_request "$BASE_URL" > /dev/null; then
        local end_time=$(date +%s%N)
        local response_time=$(( (end_time - start_time) / 1000000 ))
        
        if [[ $response_time -lt 3000 ]]; then
            success "Main page response time: ${response_time}ms"
            add_result "Performance - Main Page" "PASS" "${response_time}ms"
        elif [[ $response_time -lt 5000 ]]; then
            warning "Main page response time: ${response_time}ms (acceptable but slow)"
            add_result "Performance - Main Page" "WARN" "${response_time}ms"
        else
            error "Main page response time: ${response_time}ms (too slow)"
            add_result "Performance - Main Page" "FAIL" "${response_time}ms"
        fi
    else
        error "Performance test failed - couldn't reach main page"
        add_result "Performance - Main Page" "FAIL" "Page unreachable"
    fi
}

# Test 7: Security headers
test_security_headers() {
    log "Testing security headers..."
    
    local response
    response=$(curl -sI "$BASE_URL" || echo "")
    
    # Check for security headers
    local headers=(
        "X-Frame-Options"
        "X-Content-Type-Options" 
        "X-XSS-Protection"
        "Strict-Transport-Security"
    )
    
    for header in "${headers[@]}"; do
        if echo "$response" | grep -qi "$header"; then
            success "Security header $header present"
            add_result "Security Header - $header" "PASS"
        else
            warning "Security header $header missing"
            add_result "Security Header - $header" "WARN" "Header not found"
        fi
    done
}

# Test 8: SSL certificate
test_ssl_certificate() {
    log "Testing SSL certificate..."
    
    if [[ "$BASE_URL" =~ ^https:// ]]; then
        local domain=$(echo "$BASE_URL" | sed 's|https://||' | sed 's|/.*||')
        
        if openssl s_client -connect "$domain:443" -servername "$domain" < /dev/null 2>/dev/null | grep -q "Verify return code: 0"; then
            success "SSL certificate valid"
            add_result "SSL Certificate" "PASS"
        else
            error "SSL certificate invalid or expired"
            add_result "SSL Certificate" "FAIL"
        fi
    else
        warning "Not testing SSL - HTTP URL provided"
        add_result "SSL Certificate" "WARN" "HTTP URL provided"
    fi
}

# Test 9: Database connectivity (indirect)
test_database_connectivity() {
    log "Testing database connectivity (indirect)..."
    
    # Test an endpoint that requires database access
    local response
    response=$(http_request "$BASE_URL/api/health/deep")
    
    if [[ $? -eq 0 ]]; then
        if echo "$response" | grep -q '"database"'; then
            success "Database connectivity test passed"
            add_result "Database Connectivity" "PASS"
        else
            warning "Database connectivity unclear"
            add_result "Database Connectivity" "WARN" "No database status in health check"
        fi
    else
        error "Database connectivity test failed"
        add_result "Database Connectivity" "FAIL"
    fi
}

# Test 10: External service integration
test_external_services() {
    log "Testing external service integration..."
    
    # We can't directly test Google Cloud Vision without auth,
    # but we can check if the configuration is valid
    local response
    response=$(http_request "$BASE_URL/api/health/deep")
    
    if [[ $? -eq 0 ]]; then
        if echo "$response" | grep -q '"ai"'; then
            success "AI service integration test passed"
            add_result "External Services - AI" "PASS"
        else
            warning "AI service status unclear"
            add_result "External Services - AI" "WARN" "No AI service status in health check"
        fi
    else
        warning "Could not test external services"
        add_result "External Services - AI" "WARN" "Health endpoint unavailable"
    fi
}

# Generate final report
generate_final_report() {
    {
        echo "================================================"
        echo "VERIFICATION SUMMARY"
        echo "================================================"
        echo "Total Tests: $TOTAL_TESTS"
        echo "Passed: $PASSED_TESTS"
        echo "Failed: $FAILED_TESTS"
        echo "Warnings: $WARNINGS"
        echo
        
        local success_rate=0
        if [[ $TOTAL_TESTS -gt 0 ]]; then
            success_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
        fi
        echo "Success Rate: $success_rate%"
        echo
        
        if [[ $FAILED_TESTS -eq 0 ]]; then
            echo "STATUS: ✅ DEPLOYMENT VERIFICATION PASSED"
        elif [[ $FAILED_TESTS -le 2 && $success_rate -ge 80 ]]; then
            echo "STATUS: ⚠️  DEPLOYMENT VERIFICATION PASSED WITH WARNINGS"
        else
            echo "STATUS: ❌ DEPLOYMENT VERIFICATION FAILED"
        fi
        
        echo "================================================"
        echo "Report saved to: $REPORT_FILE"
        echo "================================================"
    } >> "$REPORT_FILE"
    
    # Display summary
    cat "$REPORT_FILE" | tail -20
}

# Show usage
show_usage() {
    echo "Usage: $0 [ENVIRONMENT] [BASE_URL]"
    echo
    echo "ENVIRONMENT:"
    echo "  staging     - Verify staging deployment"
    echo "  production  - Verify production deployment"
    echo
    echo "BASE_URL (optional):"
    echo "  The base URL to test (defaults based on environment)"
    echo
    echo "Examples:"
    echo "  $0 staging"
    echo "  $0 production"
    echo "  $0 staging https://staging-minerva.vercel.app"
    echo "  $0 production https://minerva.yourdomain.com"
}

# Main execution
main() {
    local environment=$1
    local base_url=$2
    
    # Validate arguments
    if [[ -z "$environment" ]]; then
        error "Environment required (staging or production)"
        show_usage
        exit 1
    fi
    
    # Set default URLs based on environment
    case $environment in
        "staging")
            BASE_URL=${base_url:-"https://staging-minerva.vercel.app"}
            ;;
        "production")
            BASE_URL=${base_url:-"https://minerva.yourdomain.com"}
            ;;
        *)
            error "Invalid environment: $environment"
            show_usage
            exit 1
            ;;
    esac
    
    ENVIRONMENT=$environment
    
    log "Starting deployment verification for $environment environment"
    log "Testing URL: $BASE_URL"
    
    # Initialize report
    init_report
    
    # Run all tests
    test_basic_connectivity || true
    test_health_endpoints || true
    test_auth_pages || true
    test_api_endpoints || true
    test_static_assets || true
    test_performance || true
    test_security_headers || true
    test_ssl_certificate || true
    test_database_connectivity || true
    test_external_services || true
    
    # Generate final report
    generate_final_report
    
    # Exit with appropriate code
    if [[ $FAILED_TESTS -eq 0 ]]; then
        success "Deployment verification completed successfully!"
        exit 0
    elif [[ $FAILED_TESTS -le 2 && $((PASSED_TESTS * 100 / TOTAL_TESTS)) -ge 80 ]]; then
        warning "Deployment verification completed with warnings"
        exit 0
    else
        error "Deployment verification failed"
        exit 1
    fi
}

# Handle script termination
cleanup() {
    warning "Verification process interrupted"
    if [[ -f "$REPORT_FILE" ]]; then
        log "Partial report available at: $REPORT_FILE"
    fi
    exit 1
}

trap cleanup SIGINT SIGTERM

# Run main function
main "$@"