#!/bin/bash
# Master test runner script
# This script runs all tests and validations for the LF9 project

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

print_header() {
    echo ""
    echo "═══════════════════════════════════════════"
    echo "  $1"
    echo "═══════════════════════════════════════════"
}

# Configuration
SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKIP_INTEGRATION=${SKIP_INTEGRATION:-false}
VERBOSE=${VERBOSE:-false}

# Test results tracking
declare -a test_results=()

# Run a test and track results
run_test() {
    local test_name="$1"
    local test_script="$2"
    local optional="${3:-false}"
    
    print_header "$test_name"
    
    if [[ ! -x "$test_script" ]]; then
        print_error "Test script not found or not executable: $test_script"
        test_results+=("FAIL:$test_name")
        return 1
    fi
    
    if [[ "$VERBOSE" == "true" ]]; then
        if "$test_script"; then
            print_status "$test_name PASSED"
            test_results+=("PASS:$test_name")
            return 0
        else
            if [[ "$optional" == "true" ]]; then
                print_warning "$test_name FAILED (optional)"
                test_results+=("WARN:$test_name")
                return 0
            else
                print_error "$test_name FAILED"
                test_results+=("FAIL:$test_name")
                return 1
            fi
        fi
    else
        # Capture output for non-verbose mode
        if output=$("$test_script" 2>&1); then
            print_status "$test_name PASSED"
            test_results+=("PASS:$test_name")
            return 0
        else
            if [[ "$optional" == "true" ]]; then
                print_warning "$test_name FAILED (optional)"
                if [[ "$VERBOSE" == "true" ]]; then
                    echo "$output"
                fi
                test_results+=("WARN:$test_name")
                return 0
            else
                print_error "$test_name FAILED"
                echo "$output"
                test_results+=("FAIL:$test_name")
                return 1
            fi
        fi
    fi
}

# Print test summary
print_summary() {
    print_header "TEST SUMMARY"
    
    local passed=0
    local failed=0
    local warnings=0
    
    for result in "${test_results[@]}"; do
        local status="${result%%:*}"
        local test_name="${result#*:}"
        
        case "$status" in
            "PASS")
                print_status "$test_name"
                ((passed++))
                ;;
            "FAIL")
                print_error "$test_name"
                ((failed++))
                ;;
            "WARN")
                print_warning "$test_name"
                ((warnings++))
                ;;
        esac
    done
    
    echo ""
    echo "Results: $passed passed, $failed failed, $warnings warnings"
    
    if [[ $failed -gt 0 ]]; then
        print_error "❌ Some tests failed!"
        return 1
    elif [[ $warnings -gt 0 ]]; then
        print_warning "⚠️  All critical tests passed, but there are warnings"
        return 0
    else
        print_status "🎉 All tests passed!"
        return 0
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -v, --verbose           Enable verbose output"
    echo "  -s, --skip-integration  Skip integration tests"
    echo "  --quality-only          Run only quality checks"
    echo "  --security-only         Run only security checks"
    echo "  --validation-only       Run only validation checks"
    echo ""
    echo "Environment variables:"
    echo "  SKIP_INTEGRATION=true   Skip integration tests"
    echo "  VERBOSE=true            Enable verbose output"
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -s|--skip-integration)
                SKIP_INTEGRATION=true
                shift
                ;;
            --quality-only)
                QUALITY_ONLY=true
                shift
                ;;
            --security-only)
                SECURITY_ONLY=true
                shift
                ;;
            --validation-only)
                VALIDATION_ONLY=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Main function
main() {
    parse_args "$@"
    
    print_info "🚀 Starting comprehensive test suite for LF9 project"
    print_info "Working directory: $PROJECT_ROOT"
    
    # Change to project root
    cd "$PROJECT_ROOT"
    
    # Pre-flight checks
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    # Run tests based on options
    if [[ "${VALIDATION_ONLY:-}" == "true" ]]; then
        run_test "Docker Compose Validation" "$SCRIPT_DIR/validate-compose.sh"
    elif [[ "${SECURITY_ONLY:-}" == "true" ]]; then
        run_test "Security Checks" "$SCRIPT_DIR/security-check.sh"
    elif [[ "${QUALITY_ONLY:-}" == "true" ]]; then
        run_test "Code Quality Checks" "$SCRIPT_DIR/quality-check.sh" true
    else
        # Run all tests
        run_test "Docker Compose Validation" "$SCRIPT_DIR/validate-compose.sh"
        run_test "Security Checks" "$SCRIPT_DIR/security-check.sh"
        run_test "Code Quality Checks" "$SCRIPT_DIR/quality-check.sh" true
        
        if [[ "$SKIP_INTEGRATION" != "true" ]]; then
            run_test "Integration Tests" "$SCRIPT_DIR/integration-test.sh"
        else
            print_info "Skipping integration tests (use -s flag or SKIP_INTEGRATION=true)"
        fi
    fi
    
    # Print summary and exit with appropriate code
    print_summary
}

main "$@"