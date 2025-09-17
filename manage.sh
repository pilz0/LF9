#!/bin/bash

# LF9 Project Management Script
# Provides easy management commands for the LF9 multi-service environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Show help
show_help() {
    echo "LF9 Project Management Script"
    echo "=============================="
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  setup     - Initial setup (copy .env.example, create directories)"
    echo "  validate  - Validate environment and configuration"
    echo "  start     - Start all services"
    echo "  stop      - Stop all services"
    echo "  restart   - Restart all services"
    echo "  status    - Show status of all services"
    echo "  logs      - Show logs from all services"
    echo "  update    - Update and restart services"
    echo "  backup    - Create backup of data volumes"
    echo "  restore   - Restore from backup"
    echo "  clean     - Remove stopped containers and unused images"
    echo "  reset     - Reset everything (DANGEROUS - removes all data)"
    echo "  urls      - Show service URLs"
    echo ""
    echo "Service-specific commands:"
    echo "  logs [service]    - Show logs for specific service"
    echo "  restart [service] - Restart specific service"
    echo "  shell [service]   - Open shell in service container"
    echo ""
    echo "Examples:"
    echo "  $0 setup"
    echo "  $0 start"
    echo "  $0 logs wordpress"
    echo "  $0 restart grafana"
    echo "  $0 shell vm_debian"
}

# Setup function
setup() {
    info "Setting up LF9 environment..."
    
    # Copy environment file
    if [ ! -f ".env" ]; then
        cp .env.example .env
        success "Created .env file from template"
        warning "Please edit .env file to set secure passwords!"
    else
        warning ".env file already exists"
    fi
    
    # Create data directories
    mkdir -p ftp1 ftp2 ftp_pub smb_user1 smb_user2 smb_public wiki_data
    success "Created data directories"
    
    # Set permissions
    chmod 755 validate.sh
    success "Set script permissions"
    
    info "Setup complete! Next steps:"
    echo "1. Edit .env file: nano .env"
    echo "2. Validate setup: ./manage.sh validate"
    echo "3. Start services: ./manage.sh start"
}

# Validate function
validate() {
    info "Running validation..."
    if [ -x "./validate.sh" ]; then
        ./validate.sh
    else
        error "validate.sh not found or not executable"
    fi
}

# Start services
start() {
    info "Starting LF9 services..."
    docker compose up -d
    success "All services started"
    show_urls
}

# Stop services
stop() {
    info "Stopping LF9 services..."
    docker compose down
    success "All services stopped"
}

# Restart services
restart() {
    if [ -n "$2" ]; then
        info "Restarting service: $2"
        docker compose restart "$2"
        success "Service $2 restarted"
    else
        info "Restarting all services..."
        docker compose restart
        success "All services restarted"
    fi
}

# Show status
status() {
    info "Service Status:"
    docker compose ps --format table
}

# Show logs
logs() {
    if [ -n "$2" ]; then
        info "Showing logs for service: $2"
        docker compose logs -f "$2"
    else
        info "Showing logs for all services:"
        docker compose logs -f
    fi
}

# Update services
update() {
    info "Updating LF9 services..."
    docker compose down
    git pull
    docker compose pull
    docker compose up -d
    success "Update complete"
}

# Backup data
backup() {
    BACKUP_FILE="lf9-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    info "Creating backup: $BACKUP_FILE"
    
    docker compose down
    tar -czf "$BACKUP_FILE" wiki_data ftp1 ftp2 ftp_pub smb_user1 smb_user2 smb_public .env 2>/dev/null || true
    docker compose up -d
    
    success "Backup created: $BACKUP_FILE"
}

# Restore from backup
restore() {
    if [ -z "$2" ]; then
        error "Usage: $0 restore <backup-file>"
    fi
    
    if [ ! -f "$2" ]; then
        error "Backup file not found: $2"
    fi
    
    warning "This will overwrite existing data. Continue? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        info "Restore cancelled"
        exit 0
    fi
    
    info "Restoring from backup: $2"
    docker compose down
    tar -xzf "$2"
    docker compose up -d
    success "Restore complete"
}

# Clean up
clean() {
    info "Cleaning up Docker resources..."
    docker compose down
    docker system prune -f
    docker volume prune -f
    success "Cleanup complete"
}

# Reset everything
reset() {
    warning "This will DESTROY ALL DATA. Are you sure? (type 'YES' to confirm)"
    read -r response
    if [ "$response" != "YES" ]; then
        info "Reset cancelled"
        exit 0
    fi
    
    error "Reset functionality disabled for safety. Please manually remove data if needed."
}

# Show service URLs
show_urls() {
    echo ""
    info "Service URLs:"
    echo "🌐 WordPress:     http://localhost:8080 (user/bitnami)"
    echo "📊 Grafana:       http://localhost:3000 (admin/admin)"
    echo "🖥️  VNC Desktop:   http://localhost:6901 (password: vncpassword)"
    echo "📝 WikiJS:        http://localhost:3001 (setup required)"
    echo "📈 Prometheus:    http://localhost:9090 (no auth)"
    echo "📁 FTP Server:    ftp://localhost:21 (user1/user2)"
    echo "📂 SMB Shares:    \\\\localhost (Benutzer1/Benutzer2)"
    echo ""
    echo "🔧 Management:"
    echo "   Validation:    ./validate.sh"
    echo "   Management:    ./manage.sh --help"
    echo ""
}

# Open shell in container
shell() {
    if [ -z "$2" ]; then
        error "Usage: $0 shell <service-name>"
    fi
    
    info "Opening shell in $2..."
    docker compose exec "$2" /bin/bash || docker compose exec "$2" /bin/sh
}

# Main script logic
case "${1:-}" in
    setup)
        setup
        ;;
    validate)
        validate
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart "$@"
        ;;
    status)
        status
        ;;
    logs)
        logs "$@"
        ;;
    update)
        update
        ;;
    backup)
        backup
        ;;
    restore)
        restore "$@"
        ;;
    clean)
        clean
        ;;
    reset)
        reset
        ;;
    urls)
        show_urls
        ;;
    shell)
        shell "$@"
        ;;
    -h|--help|help|"")
        show_help
        ;;
    *)
        error "Unknown command: $1. Use '$0 --help' for usage information."
        ;;
esac