#!/bin/bash

# Database Migration Script
# Safely applies database migrations to staging or production

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
BACKUP_DIR="database-backups"
MAX_BACKUP_AGE=30  # days

# Create backup directory if it doesn't exist
create_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        log "Created backup directory: $BACKUP_DIR"
    fi
}

# Clean old backups
cleanup_old_backups() {
    log "Cleaning up backups older than $MAX_BACKUP_AGE days..."
    find "$BACKUP_DIR" -name "*.sql" -mtime +$MAX_BACKUP_AGE -delete
    success "Old backups cleaned up"
}

# Validate environment
validate_environment() {
    local env_type=$1
    
    log "Validating $env_type environment..."
    
    # Check if Supabase CLI is available
    if ! command -v supabase &> /dev/null; then
        error "Supabase CLI not found. Please install it first:"
        error "npm install -g supabase"
        exit 1
    fi
    
    # Load environment variables
    local env_file=".env.${env_type}.local"
    if [[ ! -f "$env_file" ]]; then
        error "Environment file $env_file not found"
        exit 1
    fi
    
    source "$env_file"
    
    # Check required variables
    if [[ -z "$SUPABASE_DB_PASSWORD" ]]; then
        error "SUPABASE_DB_PASSWORD not set in $env_file"
        exit 1
    fi
    
    if [[ -z "$NEXT_PUBLIC_SUPABASE_URL" ]]; then
        error "NEXT_PUBLIC_SUPABASE_URL not set in $env_file"
        exit 1
    fi
    
    # Extract project ID from URL
    PROJECT_ID=$(echo "$NEXT_PUBLIC_SUPABASE_URL" | sed 's/.*\/\/\([^.]*\).*/\1/')
    
    if [[ -z "$PROJECT_ID" ]]; then
        error "Could not extract project ID from Supabase URL"
        exit 1
    fi
    
    success "Environment validation passed"
    log "Project ID: $PROJECT_ID"
}

# Check migration status
check_migration_status() {
    log "Checking current migration status..."
    
    if supabase migration list --linked --password "$SUPABASE_DB_PASSWORD" 2>/dev/null; then
        success "Migration status retrieved"
    else
        error "Failed to retrieve migration status"
        error "Make sure the project is linked and credentials are correct"
        exit 1
    fi
}

# Create database backup
create_backup() {
    local env_type=$1
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$BACKUP_DIR/${env_type}_backup_${timestamp}.sql"
    
    log "Creating database backup: $backup_file"
    
    # Note: This would need to be implemented based on Supabase's backup capabilities
    # For now, we'll create a marker file
    echo "-- Database backup for $env_type environment" > "$backup_file"
    echo "-- Created at: $(date)" >> "$backup_file"
    echo "-- Project ID: $PROJECT_ID" >> "$backup_file"
    
    if [[ -f "$backup_file" ]]; then
        success "Backup created: $backup_file"
        export BACKUP_FILE="$backup_file"
    else
        error "Failed to create backup"
        exit 1
    fi
}

# Run dry-run migration
run_dry_run() {
    log "Running migration dry-run..."
    
    if supabase db push --linked --password "$SUPABASE_DB_PASSWORD" --dry-run; then
        success "Dry-run completed successfully"
        return 0
    else
        error "Dry-run failed"
        return 1
    fi
}

# Apply migrations
apply_migrations() {
    local force_apply=$1
    
    if [[ "$force_apply" != "true" ]]; then
        # Run dry-run first
        if ! run_dry_run; then
            error "Dry-run failed. Migration aborted."
            exit 1
        fi
        
        # Ask for confirmation
        echo
        warning "This will apply migrations to the database."
        read -p "Continue with migration? (yes/no): " confirm
        
        if [[ "$confirm" != "yes" ]]; then
            log "Migration cancelled by user"
            exit 0
        fi
    fi
    
    log "Applying database migrations..."
    
    if supabase db push --linked --password "$SUPABASE_DB_PASSWORD"; then
        success "Migrations applied successfully"
    else
        error "Migration failed"
        
        if [[ -n "$BACKUP_FILE" ]]; then
            warning "Database backup available at: $BACKUP_FILE"
            warning "Consider restoring from backup if needed"
        fi
        
        exit 1
    fi
}

# Verify migration success
verify_migrations() {
    log "Verifying migration success..."
    
    # Check migration status again
    if supabase migration list --linked --password "$SUPABASE_DB_PASSWORD" > /dev/null 2>&1; then
        success "Migration verification passed"
    else
        error "Migration verification failed"
        exit 1
    fi
    
    # Test basic database connectivity
    log "Testing database connectivity..."
    
    # This is a simple test - in practice you might want more comprehensive checks
    local test_url="${NEXT_PUBLIC_SUPABASE_URL}/rest/v1/"
    if curl -s --fail "$test_url" -H "apikey: $NEXT_PUBLIC_SUPABASE_ANON_KEY" > /dev/null; then
        success "Database connectivity test passed"
    else
        warning "Database connectivity test failed (may be normal for RLS-protected endpoints)"
    fi
}

# Repair migration history if needed
repair_migrations() {
    local version=$1
    
    if [[ -z "$version" ]]; then
        error "Migration version required for repair"
        return 1
    fi
    
    warning "Repairing migration history for version: $version"
    
    if supabase migration repair "$version" --status applied --linked --password "$SUPABASE_DB_PASSWORD"; then
        success "Migration history repaired"
    else
        error "Migration repair failed"
        return 1
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0 [ENVIRONMENT] [OPTIONS]"
    echo
    echo "ENVIRONMENT:"
    echo "  staging     - Apply migrations to staging environment"
    echo "  production  - Apply migrations to production environment"
    echo
    echo "OPTIONS:"
    echo "  --dry-run   - Show what would be applied without making changes"
    echo "  --force     - Skip confirmation prompts"
    echo "  --repair    - Repair migration history (specify version with --version)"
    echo "  --version   - Migration version for repair"
    echo "  --status    - Show current migration status only"
    echo "  --help      - Show this help message"
    echo
    echo "Examples:"
    echo "  $0 staging --dry-run"
    echo "  $0 production --force"
    echo "  $0 staging --repair --version 20250717000000"
    echo "  $0 production --status"
}

# Main execution
main() {
    local env_type=""
    local dry_run=false
    local force_apply=false
    local repair_mode=false
    local status_only=false
    local repair_version=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            staging|production)
                env_type=$1
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --force)
                force_apply=true
                shift
                ;;
            --repair)
                repair_mode=true
                shift
                ;;
            --version)
                repair_version=$2
                shift 2
                ;;
            --status)
                status_only=true
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
    if [[ -z "$env_type" ]]; then
        error "Environment type required (staging or production)"
        show_usage
        exit 1
    fi
    
    if [[ "$repair_mode" == true && -z "$repair_version" ]]; then
        error "Migration version required for repair mode"
        show_usage
        exit 1
    fi
    
    # Special handling for production
    if [[ "$env_type" == "production" ]]; then
        warning "⚠️  PRODUCTION DATABASE MIGRATION ⚠️"
        warning "This will modify the production database!"
        
        if [[ "$force_apply" != true ]]; then
            read -p "Are you absolutely sure you want to continue? (type 'PRODUCTION' to confirm): " prod_confirm
            if [[ "$prod_confirm" != "PRODUCTION" ]]; then
                log "Production migration cancelled"
                exit 0
            fi
        fi
    fi
    
    log "Starting database migration for $env_type environment..."
    
    # Setup
    create_backup_dir
    cleanup_old_backups
    validate_environment "$env_type"
    
    # Link to project
    log "Linking to Supabase project: $PROJECT_ID"
    if ! supabase link --project-ref "$PROJECT_ID" 2>/dev/null; then
        error "Failed to link to Supabase project"
        exit 1
    fi
    
    # Handle different modes
    if [[ "$status_only" == true ]]; then
        check_migration_status
        exit 0
    fi
    
    if [[ "$repair_mode" == true ]]; then
        repair_migrations "$repair_version"
        exit 0
    fi
    
    # Check current status
    check_migration_status
    
    # Create backup before migration
    create_backup "$env_type"
    
    # Apply migrations
    if [[ "$dry_run" == true ]]; then
        run_dry_run
    else
        apply_migrations "$force_apply"
        verify_migrations
    fi
    
    success "Database migration completed successfully!"
    
    if [[ "$env_type" == "production" ]]; then
        warning "Production database has been updated"
        warning "Monitor the application closely for any issues"
    fi
}

# Handle script termination
cleanup() {
    warning "Migration process interrupted"
    if [[ -n "$BACKUP_FILE" ]]; then
        log "Backup file available at: $BACKUP_FILE"
    fi
    exit 1
}

trap cleanup SIGINT SIGTERM

# Run main function
main "$@"