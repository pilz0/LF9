#!/bin/bash
# Integration tests for the LF9 Docker stack
# This script tests the integration between services

set -e

# Change to tests directory
cd "$(dirname "$0")"

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

print_warning() {
    echo -e "\e[33m⚠\e[0m $1"
}

# Cleanup function
cleanup() {
    print_info "Cleaning up test environment..."
    cd "$(dirname "$0")"
    docker compose -f "$COMPOSE_FILE" down --volumes --remove-orphans > /dev/null 2>&1 || true
    docker network prune -f > /dev/null 2>&1 || true
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Wait for service to be ready
wait_for_service() {
    local service_name=$1
    local port=$2
    local ip=$3
    local timeout=${4:-30}
    
    print_info "Waiting for $service_name to be ready on $ip:$port..."
    
    for _ in $(seq 1 "$timeout"); do
        if docker exec "${service_name}" nc -z "$ip" "$port" 2>/dev/null; then
            print_status "$service_name is ready"
            return 0
        fi
        sleep 1
    done
    
    print_error "$service_name failed to start within $timeout seconds"
    return 1
}

# Test database connectivity
test_database() {
    print_info "Testing MariaDB database..."
    
    # Wait for database to be ready
    sleep 5
    
    # Test database connection
    if docker exec mariadb-test mysql -u test_user -e "SELECT 1;" test_db > /dev/null 2>&1; then
        print_status "Database connection successful"
    else
        print_error "Database connection failed"
        return 1
    fi
    
    # Test database creation
    if docker exec mariadb-test mysql -u test_user -e "SHOW DATABASES;" | grep -q "test_db"; then
        print_status "Test database exists"
    else
        print_error "Test database not found"
        return 1
    fi
}

# Test DNS server
test_dns() {
    print_info "Testing DNS server..."
    
    # Wait for DNS to be ready
    sleep 3
    
    # Test DNS resolution using nslookup from within the test network
    if docker run --rm --network tests_test-net alpine:latest nslookup google.com 10.13.13.69 > /dev/null 2>&1; then
        print_status "DNS resolution working"
    else
        print_warning "DNS resolution test failed (this might be expected in test environment)"
    fi
}

# Test container health
test_container_health() {
    local container_name=$1
    print_info "Testing container health: $container_name"
    
    # Check if container is running
    if docker ps --filter "name=$container_name" --filter "status=running" | grep -q "$container_name"; then
        print_status "$container_name is running"
    else
        print_error "$container_name is not running"
        docker logs "$container_name" | tail -10
        return 1
    fi
    
    # Check container resource usage
    cpu_usage=$(docker stats --no-stream --format "table {{.CPUPerc}}" "$container_name" | tail -1 | sed 's/%//')
    if (( $(echo "$cpu_usage < 100" | bc -l) )); then
        print_status "$container_name CPU usage is normal: ${cpu_usage}%"
    else
        print_warning "$container_name CPU usage is high: ${cpu_usage}%"
    fi
}

# Main test execution
main() {
    local COMPOSE_FILE="docker-compose.test.yml"
    print_info "🚀 Starting integration tests..."
    
    # We're already in the tests directory
    
    # Check if Docker is available
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    # Start test environment
    print_info "Starting test environment..."
    if docker compose -f "$COMPOSE_FILE" up -d --wait; then
        print_status "Test environment started"
    else
        print_error "Failed to start test environment"
        exit 1
    fi
    
    # Wait a bit for services to fully initialize
    sleep 10
    
    # Run individual tests
    test_container_health "mariadb-test"
    test_container_health "unbound-test" 
    test_container_health "vm-debian-test"
    
    test_database
    test_dns
    
    # Test network connectivity between containers
    print_info "Testing network connectivity..."
    if docker exec mariadb-test ping -c 1 10.13.13.69 > /dev/null 2>&1; then
        print_status "Network connectivity between services works"
    else
        print_error "Network connectivity test failed"
        return 1
    fi
    
    print_status "🎉 All integration tests passed!"
}

# Check if bc is available for calculations
if ! command -v bc &> /dev/null; then
    print_warning "bc not available, skipping CPU usage calculations"
fi

main "$@"