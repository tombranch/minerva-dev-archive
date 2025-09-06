#!/bin/bash

# Emergency Rollback Script
# Quickly rollback deployment to previous working version

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
ROLLBACK_LOG="rollback-$(date +%Y%m%d_%H%M%S).log"
VERIFICATION_TIMEOUT=300  # 5 minutes

# Initialize rollback log
init_rollback_log() {
    {
        echo "================================================"
        echo "MINERVA EMERGENCY ROLLBACK LOG"
        echo "================================================"
        echo "Date: $(date)"
        echo "Environment: $ENVIRONMENT"
        echo "Initiated by: $(whoami)"
        echo "Hostname: $(hostname)"
        echo "================================================"
        echo
    } > "$ROLLBACK_LOG"
}

# Log rollback step
log_step() {
    local step=$1
    local status=$2
    local details=$3
    
    {
        echo "[$(date +'%H:%M:%S')] $step - $status"
        if [[ -n "$details" ]]; then
            echo "    Details: $details"
        fi
        echo
    } >> "$ROLLBACK_LOG"
}

# Get current deployment info
get_current_deployment() {
    log "Getting current deployment information..."
    
    if ! command -v vercel &> /dev/null; then
        error "Vercel CLI not found"
        log_step "Get Current Deployment" "FAILED" "Vercel CLI not available"
        exit 1
    fi
    
    # Get current deployments
    local deployments
    deployments=$(vercel ls --json 2>/dev/null || echo "[]")
    
    if [[ "$deployments" == "[]" ]]; then
        error "No deployments found"
        log_step "Get Current Deployment" "FAILED" "No deployments available"
        exit 1
    fi
    
    # Extract current and previous deployment URLs
    CURRENT_DEPLOYMENT=$(echo "$deployments" | jq -r '.[0].url' 2>/dev/null || echo "")
    PREVIOUS_DEPLOYMENT=$(echo "$deployments" | jq -r '.[1].url' 2>/dev/null || echo "")
    
    if [[ -z "$CURRENT_DEPLOYMENT" ]]; then
        error "Could not determine current deployment"
        log_step "Get Current Deployment" "FAILED" "Unable to parse deployment info"
        exit 1
    fi
    
    log "Current deployment: $CURRENT_DEPLOYMENT"
    
    if [[ -n "$PREVIOUS_DEPLOYMENT" ]]; then
        log "Previous deployment: $PREVIOUS_DEPLOYMENT"
        log_step "Get Current Deployment" "SUCCESS" "Current: $CURRENT_DEPLOYMENT, Previous: $PREVIOUS_DEPLOYMENT"
    else
        warning "No previous deployment found"
        log_step "Get Current Deployment" "WARNING" "Only one deployment available"
    fi
}

# Check if rollback is needed
check_rollback_needed() {
    log "Checking if rollback is necessary..."
    
    local health_url
    if [[ "$ENVIRONMENT" == "production" ]]; then
        health_url="https://minerva.yourdomain.com/api/health"
    else
        health_url="https://staging-minerva.vercel.app/api/health"
    fi
    
    # Test current deployment health
    if curl -s --max-time 10 --fail "$health_url" > /dev/null 2>&1; then
        success "Current deployment appears healthy"
        
        read -p "Current deployment seems healthy. Continue with rollback? (yes/no): " confirm
        if [[ "$confirm" != "yes" ]]; then
            log "Rollback cancelled by user"
            log_step "Health Check" "CANCELLED" "User cancelled rollback for healthy deployment"
            exit 0
        fi
        
        log_step "Health Check" "WARNING" "Proceeding with rollback despite healthy status"
    else
        error "Current deployment is unhealthy - rollback needed"
        log_step "Health Check" "FAILED" "Current deployment unhealthy, proceeding with rollback"
    fi
}

# Create incident record
create_incident_record() {
    local reason=$1
    
    log "Creating incident record..."
    
    local incident_file="incident-$(date +%Y%m%d_%H%M%S).json"
    
    cat > "$incident_file" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "environment": "$ENVIRONMENT",
  "incident_type": "deployment_rollback",
  "reason": "$reason",
  "triggered_by": "$(whoami)",
  "current_deployment": "$CURRENT_DEPLOYMENT",
  "rollback_target": "$PREVIOUS_DEPLOYMENT",
  "hostname": "$(hostname)",
  "status": "in_progress"
}
EOF
    
    INCIDENT_FILE="$incident_file"
    log_step "Create Incident Record" "SUCCESS" "Incident record: $incident_file"
}

# Perform Vercel rollback
perform_vercel_rollback() {
    local target_deployment=$1
    
    log "Performing Vercel rollback..."
    
    if [[ -z "$target_deployment" ]]; then
        error "No target deployment specified"
        log_step "Vercel Rollback" "FAILED" "No target deployment available"
        return 1
    fi
    
    # Execute rollback
    if vercel rollback "$target_deployment" --yes 2>/dev/null; then
        success "Vercel rollback completed"
        log_step "Vercel Rollback" "SUCCESS" "Rolled back to: $target_deployment"
        return 0
    else
        error "Vercel rollback failed"
        log_step "Vercel Rollback" "FAILED" "Rollback command failed"
        return 1
    fi
}

# Alternative: Promote previous deployment
promote_previous_deployment() {
    local target_deployment=$1
    
    log "Promoting previous deployment as alternative rollback method..."
    
    if [[ -z "$target_deployment" ]]; then
        error "No target deployment to promote"
        log_step "Promote Previous" "FAILED" "No target deployment available"
        return 1
    fi
    
    # Promote the previous deployment
    if vercel promote "$target_deployment" --yes 2>/dev/null; then
        success "Previous deployment promoted"
        log_step "Promote Previous" "SUCCESS" "Promoted: $target_deployment"
        return 0
    else
        error "Failed to promote previous deployment"
        log_step "Promote Previous" "FAILED" "Promotion failed"
        return 1
    fi
}

# Verify rollback success
verify_rollback() {
    log "Verifying rollback success..."
    
    local health_url
    if [[ "$ENVIRONMENT" == "production" ]]; then
        health_url="https://minerva.yourdomain.com/api/health"
    else
        health_url="https://staging-minerva.vercel.app/api/health"
    fi
    
    local max_attempts=30
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        log "Verification attempt $attempt/$max_attempts..."
        
        if curl -s --max-time 10 --fail "$health_url" > /dev/null 2>&1; then
            success "Rollback verification successful"
            log_step "Verify Rollback" "SUCCESS" "Application responding normally after $attempt attempts"
            return 0
        fi
        
        sleep 10
        attempt=$((attempt + 1))
    done
    
    error "Rollback verification failed after $max_attempts attempts"
    log_step "Verify Rollback" "FAILED" "Application still not responding after rollback"
    return 1
}

# Notify team
notify_team() {
    local status=$1
    local reason=$2
    
    log "Notifying team of rollback status..."
    
    # Update incident record
    if [[ -f "$INCIDENT_FILE" ]]; then
        local temp_file=$(mktemp)
        jq ".status = \"$status\" | .completed_at = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" "$INCIDENT_FILE" > "$temp_file"
        mv "$temp_file" "$INCIDENT_FILE"
    fi
    
    # Slack notification (if configured)
    if [[ -n "$SLACK_WEBHOOK_URL" ]]; then
        local message
        if [[ "$status" == "completed" ]]; then
            message="🔄 Emergency rollback completed for $ENVIRONMENT environment"
        else
            message="❌ Emergency rollback failed for $ENVIRONMENT environment"
        fi
        
        curl -X POST "$SLACK_WEBHOOK_URL" \
            -H 'Content-Type: application/json' \
            -d "{\"text\": \"$message\nReason: $reason\nTime: $(date)\"}" \
            2>/dev/null || true
    fi
    
    log_step "Team Notification" "SUCCESS" "Notifications sent"
}

# Generate rollback report
generate_rollback_report() {
    log "Generating rollback report..."
    
    {
        echo "================================================"
        echo "ROLLBACK SUMMARY"
        echo "================================================"
        echo "Environment: $ENVIRONMENT"
        echo "Start Time: $(head -n 5 "$ROLLBACK_LOG" | tail -n 1 | cut -d' ' -f2-3)"
        echo "End Time: $(date)"
        echo "Duration: $(($(date +%s) - ROLLBACK_START_TIME)) seconds"
        echo
        echo "Deployments:"
        echo "  Current (before): $CURRENT_DEPLOYMENT"
        echo "  Target (after):   $PREVIOUS_DEPLOYMENT"
        echo
        echo "Files Created:"
        echo "  Rollback Log:     $ROLLBACK_LOG"
        if [[ -f "$INCIDENT_FILE" ]]; then
            echo "  Incident Record:  $INCIDENT_FILE"
        fi
        echo
        echo "================================================"
    } >> "$ROLLBACK_LOG"
    
    success "Rollback report generated: $ROLLBACK_LOG"
}

# Show usage
show_usage() {
    echo "Usage: $0 [ENVIRONMENT] [OPTIONS]"
    echo
    echo "ENVIRONMENT:"
    echo "  staging     - Rollback staging deployment"
    echo "  production  - Rollback production deployment"
    echo
    echo "OPTIONS:"
    echo "  --target URL     - Specific deployment URL to rollback to"
    echo "  --reason TEXT    - Reason for rollback (for incident record)"
    echo "  --force          - Skip health checks and confirmations"
    echo "  --help           - Show this help message"
    echo
    echo "Examples:"
    echo "  $0 production --reason 'Database connection issues'"
    echo "  $0 staging --force"
    echo "  $0 production --target https://minerva-abc123.vercel.app"
}

# Main execution
main() {
    local environment=""
    local target_deployment=""
    local reason="Manual rollback request"
    local force_rollback=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            staging|production)
                environment=$1
                shift
                ;;
            --target)
                target_deployment=$2
                shift 2
                ;;
            --reason)
                reason=$2
                shift 2
                ;;
            --force)
                force_rollback=true
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
        error "Environment required (staging or production)"
        show_usage
        exit 1
    fi
    
    ENVIRONMENT=$environment
    ROLLBACK_START_TIME=$(date +%s)
    
    # Production safety check
    if [[ "$environment" == "production" && "$force_rollback" != true ]]; then
        warning "⚠️  PRODUCTION ROLLBACK ⚠️"
        warning "This will rollback the production deployment!"
        
        read -p "Are you sure you want to rollback production? (type 'ROLLBACK' to confirm): " confirm
        if [[ "$confirm" != "ROLLBACK" ]]; then
            log "Production rollback cancelled"
            exit 0
        fi
    fi
    
    log "Starting emergency rollback for $environment environment..."
    log "Reason: $reason"
    
    # Initialize
    init_rollback_log
    create_incident_record "$reason"
    
    # Get current deployment info
    get_current_deployment
    
    # Use specified target or previous deployment
    if [[ -n "$target_deployment" ]]; then
        PREVIOUS_DEPLOYMENT="$target_deployment"
        log "Using specified target deployment: $target_deployment"
    fi
    
    if [[ -z "$PREVIOUS_DEPLOYMENT" ]]; then
        error "No target deployment available for rollback"
        log_step "Target Selection" "FAILED" "No previous deployment available"
        exit 1
    fi
    
    # Check if rollback is needed (unless forced)
    if [[ "$force_rollback" != true ]]; then
        check_rollback_needed
    fi
    
    # Perform rollback
    log "Attempting rollback to: $PREVIOUS_DEPLOYMENT"
    
    if perform_vercel_rollback "$PREVIOUS_DEPLOYMENT"; then
        success "Primary rollback method succeeded"
    elif promote_previous_deployment "$PREVIOUS_DEPLOYMENT"; then
        success "Alternative rollback method succeeded"
    else
        error "All rollback methods failed"
        log_step "Rollback Execution" "FAILED" "Both rollback and promote failed"
        notify_team "failed" "$reason"
        exit 1
    fi
    
    # Verify rollback
    if verify_rollback; then
        success "Rollback completed and verified successfully"
        notify_team "completed" "$reason"
    else
        error "Rollback completed but verification failed"
        notify_team "completed_with_issues" "$reason"
        warning "Manual investigation required"
    fi
    
    # Generate final report
    generate_rollback_report
    
    success "Emergency rollback process completed"
    
    if [[ "$environment" == "production" ]]; then
        warning "Production has been rolled back"
        warning "Investigate the root cause before attempting to redeploy"
    fi
    
    log "Review the rollback log: $ROLLBACK_LOG"
    if [[ -f "$INCIDENT_FILE" ]]; then
        log "Incident record: $INCIDENT_FILE"
    fi
}

# Handle script termination
cleanup() {
    warning "Rollback process interrupted"
    
    if [[ -f "$ROLLBACK_LOG" ]]; then
        echo "[$(date +'%H:%M:%S')] Rollback process interrupted" >> "$ROLLBACK_LOG"
        log "Partial rollback log available: $ROLLBACK_LOG"
    fi
    
    if [[ -f "$INCIDENT_FILE" ]]; then
        local temp_file=$(mktemp)
        jq ".status = \"interrupted\" | .interrupted_at = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" "$INCIDENT_FILE" > "$temp_file"
        mv "$temp_file" "$INCIDENT_FILE"
    fi
    
    exit 1
}

trap cleanup SIGINT SIGTERM

# Run main function
main "$@"