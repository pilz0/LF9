#!/bin/bash

# LF9 Project Validation Script
# This script validates the environment and setup

set -e

echo "🔍 LF9 Project Validation Script"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check functions
check_passed() {
    echo -e "${GREEN}✅ $1${NC}"
}

check_failed() {
    echo -e "${RED}❌ $1${NC}"
}

check_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 1. Check if Docker is installed and running
echo ""
echo "1. Checking Docker installation..."
if command -v docker &> /dev/null; then
    check_passed "Docker is installed"
    
    if docker info &> /dev/null; then
        check_passed "Docker daemon is running"
    else
        check_failed "Docker daemon is not running. Try: sudo systemctl start docker"
        exit 1
    fi
else
    check_failed "Docker is not installed. Please install Docker first."
    exit 1
fi

# 2. Check Docker Compose
echo ""
echo "2. Checking Docker Compose..."
if docker compose version &> /dev/null; then
    check_passed "Docker Compose is available"
else
    check_failed "Docker Compose is not available. Please install docker-compose-plugin"
    exit 1
fi

# 3. Check docker-compose.yml syntax
echo ""
echo "3. Validating docker-compose.yml..."
if docker compose config --quiet; then
    check_passed "docker-compose.yml syntax is valid"
else
    check_failed "docker-compose.yml has syntax errors"
    exit 1
fi

# 4. Check environment configuration
echo ""
echo "4. Checking environment configuration..."
if [ -f ".env" ]; then
    check_passed ".env file exists"
    
    # Check for default passwords
    if grep -q "your_secure_password_here\|your_secure_" .env; then
        check_warning "Default passwords detected in .env file. Please update them for security."
    else
        check_passed "Passwords appear to be customized"
    fi
else
    check_warning ".env file not found. Consider copying .env.example to .env"
fi

# 5. Check available ports
echo ""
echo "5. Checking port availability..."
PORTS=(5901 6901 8080 3000 21 53)
for port in "${PORTS[@]}"; do
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        check_warning "Port $port is already in use"
    else
        check_passed "Port $port is available"
    fi
done

# 6. Check system resources
echo ""
echo "6. Checking system resources..."

# Check RAM
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
if [ "$RAM_GB" -ge 4 ]; then
    check_passed "Sufficient RAM available (${RAM_GB}GB)"
else
    check_warning "Limited RAM available (${RAM_GB}GB). Recommended: 4GB+"
fi

# Check disk space
DISK_GB=$(df -BG . | awk 'NR==2{print $4}' | sed 's/G//')
if [ "$DISK_GB" -ge 15 ]; then
    check_passed "Sufficient disk space available (${DISK_GB}GB)"
else
    check_warning "Limited disk space available (${DISK_GB}GB). Recommended: 15GB+"
fi

# 7. Check for required directories
echo ""
echo "7. Checking directory structure..."
REQUIRED_DIRS=("src" "docs")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        check_passed "Directory $dir exists"
    else
        check_failed "Directory $dir is missing"
    fi
done

# 8. Check if services are running (optional)
echo ""
echo "8. Checking running services..."
if docker compose ps --format table 2>/dev/null | grep -q "Up"; then
    check_passed "Some services are running"
    echo ""
    echo "Running services:"
    docker compose ps --format table
else
    echo "ℹ️  No services are currently running. Use 'docker compose up -d' to start them."
fi

echo ""
echo "🎉 Validation complete!"
echo ""
echo "Next steps:"
echo "1. If not done already: cp .env.example .env && nano .env"
echo "2. Start services: docker compose up -d"
echo "3. Check status: docker compose ps"
echo "4. View logs: docker compose logs"