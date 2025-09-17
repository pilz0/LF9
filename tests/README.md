# LF9 Testing Framework

This directory contains comprehensive testing and validation scripts for the LF9 Docker infrastructure project.

## Overview

The testing framework provides multiple layers of validation:

- **Configuration Validation**: Ensures Docker Compose files are syntactically correct and properly configured
- **Security Checks**: Performs security audits on containers, configurations, and code
- **Quality Assurance**: Lints shell scripts and YAML files for best practices
- **Integration Tests**: Validates that services can start and communicate properly

## Test Scripts

### `run-all-tests.sh`
Master test runner that executes all test suites.

```bash
# Run all tests
./tests/run-all-tests.sh

# Run with verbose output
./tests/run-all-tests.sh --verbose

# Skip integration tests (useful for CI)
./tests/run-all-tests.sh --skip-integration

# Run only specific test types
./tests/run-all-tests.sh --validation-only
./tests/run-all-tests.sh --security-only
./tests/run-all-tests.sh --quality-only
```

### `validate-compose.sh`
Validates Docker Compose configuration files.

**What it checks:**
- Docker Compose syntax validation
- Required configuration files existence
- Network configuration validation
- Service dependency validation
- Image name format validation
- IP address conflict detection

### `security-check.sh`
Performs security validation on the Docker setup.

**What it checks:**
- Potential secrets in configuration files
- Privileged container usage
- Host network mode usage
- Sensitive path mounts
- Root user usage
- File permission issues
- Network security configurations

### `quality-check.sh`
Performs code quality checks and linting.

**What it checks:**
- Shell script linting with ShellCheck
- YAML file validation with yamllint
- Shell script best practices
- Docker Compose quality standards

### `integration-test.sh`
Runs integration tests using a test environment.

**What it tests:**
- Container startup and health
- Database connectivity
- DNS resolution
- Network connectivity between services
- Service resource usage

### `docker-compose.test.yml`
Test configuration with a minimal subset of services for integration testing.

## Usage in CI/CD

The tests are integrated into the GitHub Actions workflow (`enhanced-ci-cd.yml`) and run automatically on:

- Push to main branches
- Pull requests
- Manual workflow dispatch

### CI/CD Pipeline Stages

1. **Validation & Quality Checks**
   - Configuration validation
   - Security checks
   - Code quality assessment

2. **Integration Tests**
   - Build test image
   - Run integration test suite

3. **Security Scanning**
   - Trivy vulnerability scanning
   - Hadolint Dockerfile linting

4. **Build & Push**
   - Multi-architecture Docker build
   - Image signing with Cosign
   - Container registry push

5. **Post-deployment Verification**
   - Image pull verification
   - Smoke tests

## Local Development

### Prerequisites

- Docker and Docker Compose
- Bash shell
- Basic Unix tools (grep, find, etc.)

### Optional Tools for Enhanced Checks

```bash
# Install linting tools
sudo apt-get install shellcheck yamllint

# Or using pip
pip install yamllint
```

### Running Tests Locally

```bash
# Make sure you're in the project root
cd /path/to/LF9

# Run all tests
./tests/run-all-tests.sh

# Run specific test types
./tests/validate-compose.sh
./tests/security-check.sh
./tests/quality-check.sh
./tests/integration-test.sh
```

## Test Configuration

### Environment Variables

- `SKIP_INTEGRATION=true` - Skip integration tests
- `VERBOSE=true` - Enable verbose output
- `CI=true` - Automatically install required tools

### Test Network

Integration tests use a separate Docker network (`10.13.13.0/24`) to avoid conflicts with the main application network.

## Adding New Tests

1. Create your test script in the `tests/` directory
2. Make it executable: `chmod +x tests/your-test.sh`
3. Add appropriate error handling and colored output
4. Update `run-all-tests.sh` to include your test
5. Update this README

### Test Script Template

```bash
#!/bin/bash
set -e

# Function to print colored output
print_status() { echo -e "\e[32m✓\e[0m $1"; }
print_error() { echo -e "\e[31m✗\e[0m $1"; }
print_info() { echo -e "\e[34mℹ\e[0m $1"; }
print_warning() { echo -e "\e[33m⚠\e[0m $1"; }

# Your test logic here
print_info "Starting your test..."

# Test implementation
if your_test_condition; then
    print_status "Test passed"
else
    print_error "Test failed"
    exit 1
fi

print_status "Your test completed successfully!"
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   chmod +x tests/*.sh
   ```

2. **Docker Not Available**
   Ensure Docker is installed and the daemon is running

3. **Network Conflicts**
   The test network (`10.13.13.0/24`) must not conflict with existing networks

4. **Missing Tools**
   Install optional tools for enhanced checking:
   ```bash
   sudo apt-get install shellcheck yamllint bc
   ```

### Debug Mode

Run tests with verbose output to see detailed information:

```bash
./tests/run-all-tests.sh --verbose
```

## Contributing

When contributing to the testing framework:

1. Follow the existing code style and patterns
2. Add appropriate documentation
3. Test your changes locally
4. Update this README if needed
5. Ensure all tests pass before submitting

## Security Considerations

The security checks are basic validations. For production environments, consider:

- Regular vulnerability scanning with tools like Trivy
- Container security benchmarks (docker-bench-security)
- Static analysis tools for Dockerfiles (hadolint)
- Runtime security monitoring
- Regular dependency updates