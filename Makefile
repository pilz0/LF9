# LF9 Project Makefile
# Provides convenient commands for testing, building, and managing the project

.PHONY: help test test-quick test-integration validate security quality build up down clean

# Default target
help: ## Show this help message
	@echo "LF9 Project - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Environment Variables:"
	@echo "  VERBOSE=true     Enable verbose test output"
	@echo "  CI=true          Run in CI mode (auto-install tools)"

# Testing targets
test: ## Run all tests (excluding integration tests)
	@echo "🧪 Running all tests..."
	./tests/run-all-tests.sh --skip-integration

test-quick: ## Run quick validation and security checks only
	@echo "⚡ Running quick tests..."
	./tests/run-all-tests.sh --validation-only
	./tests/run-all-tests.sh --security-only

test-integration: ## Run integration tests (requires Docker)
	@echo "🔗 Running integration tests..."
	./tests/integration-test.sh

test-full: ## Run all tests including integration tests
	@echo "🚀 Running full test suite..."
	./tests/run-all-tests.sh

# Individual test categories
validate: ## Run configuration validation
	@echo "✅ Running validation checks..."
	./tests/validate-compose.sh

security: ## Run security checks
	@echo "🔒 Running security checks..."
	./tests/security-check.sh

quality: ## Run code quality checks
	@echo "🎯 Running quality checks..."
	./tests/quality-check.sh

# Docker management
build: ## Build the Docker image locally
	@echo "🏗️ Building Docker image..."
	docker build -f Dockerfile-vm_debian -t lf9:local .

up: ## Start all services
	@echo "🚀 Starting all services..."
	docker compose up -d

down: ## Stop all services
	@echo "🛑 Stopping all services..."
	docker compose down

logs: ## Show logs from all services
	@echo "📋 Showing service logs..."
	docker compose logs -f

status: ## Show status of all services
	@echo "📊 Service status:"
	docker compose ps

# Maintenance
clean: ## Clean up Docker resources
	@echo "🧹 Cleaning up..."
	docker compose down --volumes --remove-orphans || true
	docker system prune -f

clean-all: ## Clean up all Docker resources (including images)
	@echo "🧹 Deep cleaning..."
	docker compose down --volumes --remove-orphans || true
	docker system prune -af

# Development helpers
install-tools: ## Install testing tools (shellcheck, yamllint)
	@echo "🔧 Installing testing tools..."
	@if command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get update && sudo apt-get install -y shellcheck; \
	elif command -v brew >/dev/null 2>&1; then \
		brew install shellcheck; \
	else \
		echo "⚠️ Please install shellcheck manually"; \
	fi
	@if command -v pip3 >/dev/null 2>&1; then \
		pip3 install --user yamllint; \
	elif command -v pip >/dev/null 2>&1; then \
		pip install --user yamllint; \
	else \
		echo "⚠️ Please install yamllint manually"; \
	fi

fix-permissions: ## Fix file permissions for scripts
	@echo "🔧 Fixing script permissions..."
	find . -name "*.sh" -type f -exec chmod +x {} \;

# Quick shortcuts
lint: quality ## Alias for quality checks
check: validate ## Alias for validation
scan: security ## Alias for security checks