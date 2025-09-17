#!/bin/bash
# Validation script for Docker Compose configuration
# This script validates the main docker-compose.yml file

set -e

echo "🔍 Starting Docker Compose validation..."

# Function to print colored output
print_status() {
    echo -e "\e[32m✓\e[0m $1"
}

print_error() {
    echo -e "\e[31m✗\e[0m $1"
}

print_info() {
    echo -e "\e[34mℹ\e[0m $1"
}

# Change to repository root
cd "$(dirname "$0")/.."

# Check if docker-compose.yml exists
if [[ ! -f docker-compose.yml ]]; then
    print_error "docker-compose.yml not found!"
    exit 1
fi

print_status "docker-compose.yml found"

# Validate docker-compose syntax
print_info "Validating Docker Compose syntax..."
if docker compose config > /dev/null 2>&1; then
    print_status "Docker Compose syntax is valid"
else
    print_error "Docker Compose syntax validation failed"
    docker compose config
    exit 1
fi

# Check required files exist
print_info "Checking required configuration files..."

required_files=(
    "a-records.conf"
    "forward-records.conf"
    "prometheus.yml"
    "dashboard_grafana.yml"
    "datasource_prometheus.yml"
    "Dockerfile-vm_debian"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        print_status "$file exists"
    else
        print_error "$file is missing"
        exit 1
    fi
done

# Validate network configuration
print_info "Validating network configuration..."
if docker compose config | grep -q "10.13.12.0/24"; then
    print_status "IPv4 network configuration is valid"
else
    print_error "IPv4 network configuration is invalid"
    exit 1
fi

if docker compose config | grep -q "fd69:acab:1312::/64"; then
    print_status "IPv6 network configuration is valid"
else
    print_error "IPv6 network configuration is invalid"
    exit 1
fi

# Check for duplicate IP addresses (exclude DNS references)
print_info "Checking for duplicate IP addresses..."
ipv4_addresses=$(docker compose config | grep "ipv4_address:" | grep -o "10\.13\.12\.[0-9]\+" | sort)
duplicate_ipv4=$(echo "$ipv4_addresses" | uniq -d)

if [[ -z "$duplicate_ipv4" ]]; then
    print_status "No duplicate IPv4 addresses found"
else
    print_error "Duplicate IPv4 addresses found: $duplicate_ipv4"
    exit 1
fi

# Validate service dependencies
print_info "Validating service dependencies..."
if docker compose config | grep -q "depends_on"; then
    print_status "Service dependencies are configured"
fi

# Check if images are accessible (basic check)
print_info "Checking if Docker images are accessible..."
images=$(docker compose config | grep "image:" | awk '{print $2}' | sort -u)

for image in $images; do
    print_info "Checking image: $image"
    # Note: Not pulling images in validation to save time and bandwidth
    # Just check if they're valid image names
    if [[ "$image" =~ ^[a-zA-Z0-9][a-zA-Z0-9._/-]*:[a-zA-Z0-9._-]+$ ]] || [[ "$image" =~ ^[a-zA-Z0-9][a-zA-Z0-9._/-]*$ ]]; then
        print_status "Image name format is valid: $image"
    else
        print_error "Invalid image name format: $image"
        exit 1
    fi
done

echo ""
print_status "🎉 All validations passed! Docker Compose configuration is valid."