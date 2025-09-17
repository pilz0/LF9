#!/bin/bash
# Security validation script for Docker containers and configurations
# This script performs security checks on the Docker setup

set -e

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

# Change to repository root
cd "$(dirname "$0")/.."

echo "🔒 Starting security validation..."

# Check for secrets in configuration files
check_secrets() {
    print_info "Checking for potential secrets in configuration files..."
    
    # Common secret patterns
    secret_patterns=(
        "password.*=.*[^(password)]"
        "secret.*=.*"
        "key.*=.*[a-zA-Z0-9]{20,}"
        "token.*=.*[a-zA-Z0-9]{20,}"
    )
    
    files_to_check=(
        "docker-compose.yml"
        "*.conf"
        "*.yml"
        "*.yaml"
    )
    
    secrets_found=0
    
    for pattern in "${secret_patterns[@]}"; do
        for file_pattern in "${files_to_check[@]}"; do
            if ls "$file_pattern" 1> /dev/null 2>&1; then
                for file in $file_pattern; do
                    if grep -i "$pattern" "$file" > /dev/null 2>&1; then
                        # Skip known test/example passwords
                        if ! grep -i "$pattern" "$file" | grep -q -E "(vncpassword|garlictomatofood|wikijsrocks|testpassword)"; then
                            print_warning "Potential secret found in $file"
                            grep -n -i "$pattern" "$file" | head -3
                            secrets_found=$((secrets_found + 1))
                        fi
                    fi
                done
            fi
        done
    done
    
    if [[ $secrets_found -eq 0 ]]; then
        print_status "No suspicious secrets found in configuration files"
    else
        print_warning "$secrets_found potential secrets found. Please review."
    fi
}

# Check Docker Compose security configurations
check_compose_security() {
    print_info "Checking Docker Compose security configurations..."
    
    # Check for privileged containers
    if docker compose config | grep -q "privileged.*true"; then
        print_warning "Privileged containers found. Review security implications."
    else
        print_status "No privileged containers found"
    fi
    
    # Check for host network mode
    if docker compose config | grep -q "network_mode.*host"; then
        print_warning "Host network mode found. Review security implications."
    else
        print_status "No host network mode usage found"
    fi
    
    # Check for volume mounts to sensitive host paths
    sensitive_paths=("/etc" "/var/run/docker.sock" "/proc" "/sys")
    for path in "${sensitive_paths[@]}"; do
        if docker compose config | grep -q "$path:"; then
            print_warning "Mount to sensitive host path found: $path"
        fi
    done
    
    # Check for root user usage
    if docker compose config | grep -q "user.*0"; then
        print_warning "Root user (UID 0) usage found in services"
    fi
    
    print_status "Docker Compose security check completed"
}

# Check Dockerfile security
check_dockerfile_security() {
    print_info "Checking Dockerfile security..."
    
    if [[ ! -f "Dockerfile-vm_debian" ]]; then
        print_warning "Dockerfile-vm_debian not found"
        return
    fi
    
    # Check for USER instruction
    if grep -q "^USER" "Dockerfile-vm_debian"; then
        print_status "USER instruction found in Dockerfile"
    else
        print_warning "No USER instruction found in Dockerfile (running as root)"
    fi
    
    # Check for COPY --chown usage
    if grep -q "COPY --chown" "Dockerfile-vm_debian"; then
        print_status "Proper file ownership set with COPY --chown"
    fi
    
    # Check for package manager cache cleanup
    if grep -q "apt-get clean" "Dockerfile-vm_debian" || find src/ -name "*.sh" -exec grep -l "apt-get clean" {} \; | head -1 >/dev/null 2>&1; then
        print_status "Package manager cache cleanup found"
    else
        print_warning "No package manager cache cleanup found"
    fi
    
    # Check for specific vulnerable packages (example)
    vulnerable_packages=("telnet" "rsh-server" "rsh-client")
    for package in "${vulnerable_packages[@]}"; do
        if grep -q "$package" "Dockerfile-vm_debian"; then
            print_warning "Potentially vulnerable package found: $package"
        fi
    done
    
    print_status "Dockerfile security check completed"
}

# Check network security
check_network_security() {
    print_info "Checking network security configuration..."
    
    # Check if services are exposing unnecessary ports to host
    exposed_ports=$(docker compose config | grep -E "^\s+ports:" -A 1 | grep -c -E "^\s+-")
    
    if [[ $exposed_ports -gt 5 ]]; then
        print_warning "$exposed_ports ports exposed to host. Review if all are necessary."
    else
        print_status "Reasonable number of ports ($exposed_ports) exposed to host"
    fi
    
    # Check for 0.0.0.0 bindings
    if docker compose config | grep -q "0.0.0.0:"; then
        print_warning "Services binding to 0.0.0.0 found. Consider limiting to localhost."
    else
        print_status "No wildcard IP bindings found"
    fi
    
    print_status "Network security check completed"
}

# Check file permissions
check_file_permissions() {
    print_info "Checking file permissions..."
    
    # Check for overly permissive files
    if find . -name "*.sh" -perm /o+w 2>/dev/null | grep -q .; then
        print_warning "World-writable shell scripts found:"
        find . -name "*.sh" -perm /o+w 2>/dev/null
    else
        print_status "No world-writable shell scripts found"
    fi
    
    # Check for configuration files with sensitive permissions
    config_files=("*.conf" "*.yml" "*.yaml")
    for pattern in "${config_files[@]}"; do
        if ls "$pattern" 1> /dev/null 2>&1; then
            for file in $pattern; do
                if [[ -f "$file" ]] && [[ "$(stat -c '%a' "$file")" =~ ^[0-9]*[7531]$ ]]; then
                    print_warning "Configuration file $file has overly permissive permissions: $(stat -c '%a' "$file")"
                fi
            done
        fi
    done
    
    print_status "File permissions check completed"
}

# Main function
main() {
    check_secrets
    check_compose_security
    check_dockerfile_security
    check_network_security
    check_file_permissions
    
    echo ""
    print_status "🔒 Security validation completed!"
    print_info "Note: This is a basic security check. Consider using specialized tools like:"
    print_info "  - docker-bench-security"
    print_info "  - hadolint for Dockerfile linting"
    print_info "  - trivy for vulnerability scanning"
}

main "$@"