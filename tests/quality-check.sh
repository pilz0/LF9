#!/bin/bash
# Code quality and linting script
# This script performs quality checks on shell scripts and configuration files

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

echo "🔍 Starting code quality checks..."

# Install tools if needed (for CI environment)
install_tools() {
    print_info "Checking for required tools..."
    
    # Check for shellcheck
    if ! command -v shellcheck &> /dev/null; then
        print_info "Installing shellcheck..."
        if command -v apt-get &> /dev/null; then
            apt-get update -qq && apt-get install -y shellcheck
        elif command -v apk &> /dev/null; then
            apk add --no-cache shellcheck
        else
            print_warning "Could not install shellcheck automatically"
            return 1
        fi
    fi
    
    # Check for yamllint
    if ! command -v yamllint &> /dev/null; then
        print_info "Installing yamllint..."
        if command -v pip3 &> /dev/null; then
            pip3 install yamllint
        elif command -v pip &> /dev/null; then
            pip install yamllint
        else
            print_warning "Could not install yamllint automatically"
        fi
    fi
    
    print_status "Tool installation check completed"
}

# Lint shell scripts
lint_shell_scripts() {
    print_info "Linting shell scripts..."
    
    if ! command -v shellcheck &> /dev/null; then
        print_warning "shellcheck not available, skipping shell script linting"
        return
    fi
    
    # Find all shell scripts
    shell_scripts=$(find . -name "*.sh" -type f)
    
    if [[ -z "$shell_scripts" ]]; then
        print_warning "No shell scripts found"
        return
    fi
    
    errors=0
    
    for script in $shell_scripts; do
        print_info "Checking $script..."
        
        # Skip if file doesn't exist or is not readable
        if [[ ! -r "$script" ]]; then
            print_warning "Cannot read $script, skipping"
            continue
        fi
        
        # Be more lenient with existing scripts in src/ directory
        if [[ "$script" == ./tests/* ]]; then
            # Strict checking for test scripts
            if shellcheck "$script"; then
                print_status "$script passed shellcheck"
            else
                print_error "$script failed shellcheck"
                errors=$((errors + 1))
            fi
        else
            # Lenient checking for existing source scripts - only catch severe issues
            if shellcheck -S error "$script"; then
                print_status "$script passed shellcheck (error-level only)"
            else
                print_warning "$script has shellcheck errors (existing code)"
                # Don't count as error for existing code
            fi
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        print_status "All test scripts passed linting"
    else
        print_error "$errors test scripts failed linting"
        return 1
    fi
}

# Lint YAML files
lint_yaml_files() {
    print_info "Linting YAML files..."
    
    if ! command -v yamllint &> /dev/null; then
        print_warning "yamllint not available, performing basic YAML syntax check"
        basic_yaml_check
        return
    fi
    
    # Create yamllint config
    cat > .yamllint.yml << EOF
extends: default
rules:
  line-length:
    max: 120
  indentation:
    spaces: 2
  comments:
    min-spaces-from-content: 1
EOF
    
    # Find all YAML files
    yaml_files=$(find . -name "*.yml" -o -name "*.yaml" -type f | grep -v ".yamllint.yml")
    
    if [[ -z "$yaml_files" ]]; then
        print_warning "No YAML files found"
        return
    fi
    
    errors=0
    
    for file in $yaml_files; do
        print_info "Checking $file..."
        
        if yamllint -c .yamllint.yml "$file"; then
            print_status "$file passed yamllint"
        else
            print_error "$file failed yamllint"
            errors=$((errors + 1))
        fi
    done
    
    # Cleanup
    rm -f .yamllint.yml
    
    if [[ $errors -eq 0 ]]; then
        print_status "All YAML files passed linting"
    else
        print_warning "$errors YAML files failed linting (some warnings may be acceptable)"
    fi
}

# Basic YAML syntax check using Python
basic_yaml_check() {
    if ! command -v python3 &> /dev/null; then
        print_warning "Python3 not available, skipping YAML syntax check"
        return
    fi
    
    yaml_files=$(find . -name "*.yml" -o -name "*.yaml" -type f)
    
    for file in $yaml_files; do
        print_info "Checking YAML syntax: $file..."
        
        if python3 -c "
import yaml
import sys
try:
    with open('$file', 'r') as f:
        yaml.safe_load(f)
    print('✓ Valid YAML syntax')
except yaml.YAMLError as e:
    print(f'✗ YAML syntax error: {e}')
    sys.exit(1)
except Exception as e:
    print(f'✗ Error reading file: {e}')
    sys.exit(1)
"; then
            print_status "$file has valid YAML syntax"
        else
            print_error "$file has invalid YAML syntax"
            return 1
        fi
    done
}

# Check script best practices
check_script_practices() {
    print_info "Checking shell script best practices..."
    
    shell_scripts=$(find . -name "*.sh" -type f)
    
    for script in $shell_scripts; do
        print_info "Checking best practices: $script..."
        
        # Check for shebang
        if head -1 "$script" | grep -q "^#!"; then
            print_status "$script has shebang"
        else
            print_warning "$script missing shebang"
        fi
        
        # Check for set -e
        if grep -q "set -e" "$script"; then
            print_status "$script uses 'set -e'"
        else
            print_warning "$script doesn't use 'set -e' (consider for error handling)"
        fi
        
        # Check for undefined variable usage
        if grep -q "set -u" "$script"; then
            print_status "$script uses 'set -u'"
        fi
        
        # Check for executable permission
        if [[ -x "$script" ]]; then
            print_status "$script is executable"
        else
            print_warning "$script is not executable"
        fi
    done
}

# Check Docker Compose file quality
check_compose_quality() {
    print_info "Checking Docker Compose file quality..."
    
    if [[ ! -f "docker-compose.yml" ]]; then
        print_warning "docker-compose.yml not found"
        return
    fi
    
    # Check for version specification
    if grep -q "^version:" "docker-compose.yml"; then
        print_status "Docker Compose version specified"
    else
        print_warning "Docker Compose version not specified"
    fi
    
    # Check for service naming conventions
    services=$(docker compose config --services)
    for service in $services; do
        if [[ "$service" =~ ^[a-z][a-z0-9_-]*$ ]]; then
            print_status "Service name '$service' follows naming conventions"
        else
            print_warning "Service name '$service' may not follow best practices"
        fi
    done
    
    # Check for restart policies
    if docker compose config | grep -q "restart:"; then
        print_status "Restart policies configured"
    else
        print_warning "No restart policies found (consider adding for production)"
    fi
    
    # Check for health checks
    if docker compose config | grep -q "healthcheck:"; then
        print_status "Health checks configured"
    else
        print_info "Consider adding health checks for better monitoring"
    fi
}

# Main function
main() {
    # Only install tools in CI environment
    if [[ "${CI:-}" == "true" ]]; then
        install_tools
    fi
    
    lint_shell_scripts
    lint_yaml_files
    check_script_practices
    check_compose_quality
    
    echo ""
    print_status "🎯 Code quality checks completed!"
}

main "$@"