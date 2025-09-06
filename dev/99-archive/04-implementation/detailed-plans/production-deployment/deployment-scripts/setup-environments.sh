#!/bin/bash

# Setup Environments Script
# Automates the setup of staging and production environments

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
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

# Check if required tools are installed
check_prerequisites() {
    log "Checking prerequisites..."
    
    commands=("node" "npm" "npx" "vercel" "curl" "jq")
    for cmd in "${commands[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            error "$cmd is not installed. Please install it first."
            exit 1
        fi
    done
    
    # Check Node.js version
    node_version=$(node --version | cut -d'v' -f2)
    required_version="18.17.0"
    if [[ "$(printf '%s\n' "$required_version" "$node_version" | sort -V | head -n1)" != "$required_version" ]]; then
        error "Node.js version $required_version or higher required. Found: $node_version"
        exit 1
    fi
    
    success "All prerequisites satisfied"
}

# Validate environment variables
validate_env_vars() {
    local env_type=$1
    log "Validating $env_type environment variables..."
    
    required_vars=(
        "NEXT_PUBLIC_SUPABASE_URL"
        "NEXT_PUBLIC_SUPABASE_ANON_KEY"
        "SUPABASE_SERVICE_ROLE_KEY"
        "GOOGLE_CLOUD_PROJECT_ID"
        "NEXT_PUBLIC_APP_URL"
    )
    
    local env_file=".env.${env_type}.local"
    if [[ ! -f $env_file ]]; then
        error "Environment file $env_file not found"
        return 1
    fi
    
    source $env_file
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            error "Required variable $var is not set in $env_file"
            return 1
        fi
    done
    
    # Validate URL format
    if [[ ! $NEXT_PUBLIC_SUPABASE_URL =~ ^https:// ]]; then
        error "NEXT_PUBLIC_SUPABASE_URL must start with https://"
        return 1
    fi
    
    success "$env_type environment variables validated"
}

# Test Supabase connection
test_supabase_connection() {
    local env_type=$1
    log "Testing Supabase connection for $env_type..."
    
    source ".env.${env_type}.local"
    
    # Test health endpoint
    local health_url="${NEXT_PUBLIC_SUPABASE_URL}/health"
    if curl -s --fail "$health_url" > /dev/null; then
        success "Supabase connection test passed for $env_type"
    else
        error "Supabase connection test failed for $env_type"
        return 1
    fi
}

# Setup Vercel environment variables
setup_vercel_env() {
    local env_type=$1
    local vercel_env=""
    
    case $env_type in
        "staging")
            vercel_env="preview"
            ;;
        "production")
            vercel_env="production"
            ;;
        *)
            error "Invalid environment type: $env_type"
            return 1
            ;;
    esac
    
    log "Setting up Vercel environment variables for $env_type..."
    
    source ".env.${env_type}.local"
    
    # List of variables to set in Vercel
    vars=(
        "NEXT_PUBLIC_SUPABASE_URL"
        "NEXT_PUBLIC_SUPABASE_ANON_KEY"
        "SUPABASE_SERVICE_ROLE_KEY"
        "GOOGLE_CLOUD_PROJECT_ID"
        "GOOGLE_CLOUD_CLIENT_EMAIL"
        "GOOGLE_CLOUD_PRIVATE_KEY"
        "NEXT_PUBLIC_APP_URL"
        "NEXT_PUBLIC_POSTHOG_KEY"
        "NEXT_PUBLIC_POSTHOG_HOST"
        "NEXT_PUBLIC_GOOGLE_MAPS_API_KEY"
        "NODE_ENV"
    )
    
    for var in "${vars[@]}"; do
        if [[ -n "${!var}" ]]; then
            echo "${!var}" | vercel env add "$var" "$vercel_env" --force 2>/dev/null || true
            log "Set $var for $vercel_env environment"
        else
            warning "Variable $var not found in environment file"
        fi
    done
    
    success "Vercel environment variables configured for $env_type"
}

# Create GitHub secrets
setup_github_secrets() {
    log "Setting up GitHub secrets..."
    
    if ! command -v gh &> /dev/null; then
        warning "GitHub CLI not found. Please set up GitHub secrets manually."
        warning "See 05-human-actions-checklist.md for details."
        return 0
    fi
    
    # Check if user is logged in
    if ! gh auth status &> /dev/null; then
        warning "Please login to GitHub CLI first: gh auth login"
        return 0
    fi
    
    log "GitHub CLI found and authenticated"
    
    # Get Vercel token
    read -p "Enter your Vercel token: " -s vercel_token
    echo
    
    if [[ -n "$vercel_token" ]]; then
        echo "$vercel_token" | gh secret set VERCEL_TOKEN
        success "Vercel token added to GitHub secrets"
    fi
    
    # Add other secrets
    source ".env.staging.local"
    echo "$SUPABASE_DB_PASSWORD" | gh secret set STAGING_SUPABASE_DB_PASSWORD
    
    source ".env.production.local"  
    echo "$SUPABASE_DB_PASSWORD" | gh secret set PRODUCTION_SUPABASE_DB_PASSWORD
    
    success "GitHub secrets configured"
}

# Verify setup
verify_setup() {
    local env_type=$1
    log "Verifying $env_type setup..."
    
    # Check Vercel environment variables
    if vercel env ls | grep -q "$env_type\|preview\|production"; then
        success "Vercel environment variables found"
    else
        error "Vercel environment variables not found"
        return 1
    fi
    
    # Test build
    log "Testing build process..."
    if npm run build > /dev/null 2>&1; then
        success "Build test passed"
    else
        error "Build test failed"
        return 1
    fi
    
    success "$env_type setup verification completed"
}

# Main execution
main() {
    log "Starting environment setup process..."
    
    # Check prerequisites
    check_prerequisites
    
    # Ask user which environments to set up
    echo "Which environments would you like to set up?"
    echo "1) Staging only"
    echo "2) Production only"  
    echo "3) Both staging and production"
    read -p "Enter your choice (1-3): " choice
    
    case $choice in
        1)
            environments=("staging")
            ;;
        2)
            environments=("production")
            ;;
        3)
            environments=("staging" "production")
            ;;
        *)
            error "Invalid choice"
            exit 1
            ;;
    esac
    
    # Process each environment
    for env in "${environments[@]}"; do
        log "Processing $env environment..."
        
        # Validate environment variables
        if ! validate_env_vars "$env"; then
            error "Environment validation failed for $env"
            exit 1
        fi
        
        # Test connections
        if ! test_supabase_connection "$env"; then
            error "Connection test failed for $env"
            exit 1
        fi
        
        # Setup Vercel environment
        if ! setup_vercel_env "$env"; then
            error "Vercel setup failed for $env"
            exit 1
        fi
        
        # Verify setup
        if ! verify_setup "$env"; then
            error "Setup verification failed for $env"
            exit 1
        fi
        
        success "$env environment setup completed"
    done
    
    # Setup GitHub secrets (once for all environments)
    setup_github_secrets
    
    success "Environment setup process completed successfully!"
    
    echo
    echo "Next steps:"
    echo "1. Review and test your deployments"
    echo "2. Run database migrations using migrate-database.sh"
    echo "3. Deploy to staging for testing"
    echo "4. When ready, deploy to production"
}

# Handle script termination
cleanup() {
    warning "Setup process interrupted"
    exit 1
}

trap cleanup SIGINT SIGTERM

# Run main function
main "$@"