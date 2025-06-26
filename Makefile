# RichTextExtraction Enhanced Makefile
# Provides convenient commands for development and testing

.PHONY: help test test-all quick rubocop rubocop-fix lint security coverage docs clean build install-gem dev-setup dev-quick dev-full dev-clean dev-update dev-check ci-pipeline ci-report utils-deps utils-config

# =============================================================================
# CORE TESTING COMMANDS
# =============================================================================

# Default target
help:
	@echo "🚀 RichTextExtraction Enhanced Testing Workflow"
	@echo "=============================================="
	@echo ""
	@echo "Core Testing:"
	@echo "  make test          # Run complete testing workflow"
	@echo "  make test-all      # Run all tests including performance"
	@echo "  make quick         # Quick test (RuboCop + RSpec)"
	@echo "  make rubocop       # Run RuboCop check"
	@echo "  make rubocop-fix   # Run RuboCop with auto-fix"
	@echo "  make lint          # Run all linting tools"
	@echo "  make security      # Run security audit"
	@echo "  make coverage      # Run tests with coverage"
	@echo "  make docs          # Generate documentation"
	@echo "  make clean         # Clean build artifacts"
	@echo "  make build         # Build the gem"
	@echo "  make install-gem   # Install gem locally"
	@echo ""
	@echo "Development:"
	@echo "  make dev-setup     # Setup development environment"
	@echo "  make dev-quick     # Quick development test"
	@echo "  make dev-full      # Full development test"
	@echo "  make dev-clean     # Clean development artifacts"
	@echo "  make dev-update    # Update dependencies"
	@echo "  make dev-check     # Check development environment"
	@echo ""
	@echo "CI/CD:"
	@echo "  make ci-pipeline   # Run CI pipeline"
	@echo "  make ci-report     # Generate CI report"
	@echo ""
	@echo "Utilities:"
	@echo "  make utils-deps    # Show task dependencies"
	@echo "  make utils-config  # Show configuration"
	@echo "  make help          # Show this help"
	@echo ""
	@echo "Environment Variables:"
	@echo "  COVERAGE_THRESHOLD=90      # Set coverage threshold"
	@echo "  FAIL_ON_SECURITY=true      # Fail on security issues"
	@echo "  VERBOSE=true               # Enable verbose output"
	@echo "  PARALLEL_JOBS=4            # Set parallel jobs"

# Run complete testing workflow (recommended)
test:
	@echo "🚀 Running complete testing workflow..."
	@./scripts/test.sh

# Run all tests including performance
test-all:
	@echo "🚀 Running all tests including performance..."
	@RUN_PERFORMANCE_TESTS=true ./scripts/test.sh

# Quick test (RuboCop + RSpec)
quick:
	@echo "⚡ Running quick test..."
	@RUN_COVERAGE=false RUN_DOCUMENTATION=false RUN_UNUSED_CODE_CHECK=false ./scripts/test.sh

# =============================================================================
# INDIVIDUAL TEST COMMANDS
# =============================================================================

# Run RuboCop check
rubocop:
	@echo "🔍 Running RuboCop check..."
	@bundle exec rubocop

# Run RuboCop with auto-fix (starting point)
rubocop-fix:
	@echo "🔧 Running RuboCop with auto-fix..."
	@bundle exec rubocop -A

# Run all linting tools
lint: rubocop-fix
	@echo "🔍 Running syntax check..."
	@find lib/ -name "*.rb" -exec ruby -c {} \;
	@echo "✅ All linting checks passed"

# Run security audit
security:
	@echo "🔒 Running security audit..."
	@bundle exec bundle audit check --update

# Run tests with coverage
coverage:
	@echo "📊 Running tests with coverage..."
	@COVERAGE=true bundle exec rspec --format progress --coverage

# Generate documentation
docs:
	@echo "📚 Generating documentation..."
	@bundle exec yard doc --fail-on-warning

# =============================================================================
# GEM OPERATIONS
# =============================================================================

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf pkg/
	@rm -rf tmp/
	@rm -rf coverage/
	@rm -rf doc/
	@find . -name "*.backup" -delete
	@find . -name "*.orig" -delete
	@echo "✅ Cleanup completed"

# Build the gem
build:
	@echo "📦 Building gem..."
	@bundle exec rake build

# Install gem locally
install-gem:
	@echo "📦 Installing gem locally..."
	@bundle exec rake install

# =============================================================================
# DEVELOPMENT COMMANDS
# =============================================================================

# Setup development environment
dev-setup:
	@echo "🔧 Setting up development environment..."
	@bundle install
	@mkdir -p tmp log
	@if [ -d .git ]; then \
		echo '#!/bin/bash' > .git/hooks/pre-commit; \
		echo './scripts/test.sh || exit 1' >> .git/hooks/pre-commit; \
		chmod +x .git/hooks/pre-commit; \
		echo "✅ Git hooks configured"; \
	fi
	@echo "✅ Development environment setup complete"

# Quick development test
dev-quick:
	@echo "⚡ Running quick development test..."
	@bundle exec rake dev:quick

# Full development test
dev-full:
	@echo "🚀 Running full development test..."
	@bundle exec rake dev:full

# Clean development artifacts
dev-clean:
	@echo "🧹 Cleaning development artifacts..."
	@bundle exec rake dev:clean

# Update dependencies
dev-update:
	@echo "📦 Updating dependencies..."
	@bundle update

# Check development environment
dev-check:
	@echo "🔍 Checking development environment..."
	@bundle exec rake dev:check

# =============================================================================
# CI/CD COMMANDS
# =============================================================================

# Run CI pipeline
ci-pipeline:
	@echo "🚀 Running CI pipeline..."
	@FAIL_ON_SECURITY=true FAIL_ON_LOW_COVERAGE=true VERBOSE=false ./scripts/test.sh

# Generate CI report
ci-report:
	@echo "📊 Generating CI report..."
	@bundle exec rake ci:report

# =============================================================================
# UTILITY COMMANDS
# =============================================================================

# Show task dependencies
utils-deps:
	@echo "📋 Task dependencies:"
	@bundle exec rake utils:deps

# Show configuration
utils-config:
	@echo "⚙️  Current configuration:"
	@bundle exec rake utils:config

# =============================================================================
# ADVANCED COMMANDS
# =============================================================================

# Run with custom settings
test-verbose:
	@echo "🔍 Running tests with verbose output..."
	@VERBOSE=true ./scripts/test.sh

# Run with strict settings
test-strict:
	@echo "🔒 Running tests with strict settings..."
	@FAIL_ON_SECURITY=true FAIL_ON_LOW_COVERAGE=true ./scripts/test.sh

# Run performance tests only
test-performance:
	@echo "⚡ Running performance tests..."
	@RUN_RUBOCOP=false RUN_SYNTAX_CHECK=false RUN_RSPEC_TESTS=false RUN_PERFORMANCE_TESTS=true ./scripts/test.sh

# Run with custom coverage threshold
test-coverage-90:
	@echo "📊 Running tests with 90% coverage threshold..."
	@COVERAGE_THRESHOLD=90 ./scripts/test.sh

# Run with parallel execution
test-parallel:
	@echo "⚡ Running tests with parallel execution..."
	@PARALLEL_JOBS=8 ./scripts/test.sh

# Run Rails integration tests
test-rails:
	@echo "🚂 Running Rails integration tests..."
	@RUN_RAILS_INTEGRATION=true ./scripts/test.sh

# =============================================================================
# DEBUGGING COMMANDS
# =============================================================================

# Debug configuration
debug-config:
	@echo "🔍 Debugging configuration..."
	@source scripts/config.sh && env | grep -E "(RUN_|COVERAGE_|PARALLEL_)" | sort

# Check system requirements
check-system:
	@echo "🔍 Checking system requirements..."
	@which ruby || echo "❌ Ruby not found"
	@which bundle || echo "❌ Bundler not found"
	@ruby --version
	@bundle --version

# Show test statistics
test-stats:
	@echo "📊 Test statistics:"
	@find spec/ -name "*_spec.rb" | wc -l | xargs echo "  Spec files:"
	@find lib/ -name "*.rb" | wc -l | xargs echo "  Ruby files:"
	@if [ -f coverage/.resultset.json ]; then \
		echo "  Coverage: Available"; \
	else \
		echo "  Coverage: Not available"; \
	fi

# =============================================================================
# MAINTENANCE COMMANDS
# =============================================================================

# Update all dependencies
update-all:
	@echo "📦 Updating all dependencies..."
	@bundle update
	@npm update 2>/dev/null || echo "npm not available"

# Check for outdated dependencies
check-outdated:
	@echo "🔍 Checking for outdated dependencies..."
	@bundle outdated
	@npm outdated 2>/dev/null || echo "npm not available"

# Backup current state
backup:
	@echo "💾 Creating backup..."
	@tar -czf backup-$(date +%Y%m%d_%H%M%S).tar.gz lib/ spec/ scripts/ --exclude=node_modules --exclude=tmp --exclude=coverage

# Restore from backup
restore:
	@echo "📦 Restoring from backup..."
	@if [ -z "$(BACKUP_FILE)" ]; then \
		echo "Usage: make restore BACKUP_FILE=backup-YYYYMMDD_HHMMSS.tar.gz"; \
		exit 1; \
	fi
	@tar -xzf $(BACKUP_FILE)

# =============================================================================
# DOCUMENTATION COMMANDS
# =============================================================================

# Generate all documentation
docs-all:
	@echo "📚 Generating all documentation..."
	@bundle exec yard doc --fail-on-warning
	@bundle exec yard server --reload 2>/dev/null & echo "Documentation server started at http://localhost:8808"

# Check documentation coverage
docs-coverage:
	@echo "📊 Checking documentation coverage..."
	@bundle exec yard stats --list-undoc

# Validate documentation
docs-validate:
	@echo "✅ Validating documentation..."
	@bundle exec yard doc --fail-on-warning

# =============================================================================
# PERFORMANCE COMMANDS
# =============================================================================

# Run performance benchmarks
benchmark:
	@echo "⚡ Running performance benchmarks..."
	@bundle exec ruby -r benchmark -e "Benchmark.bm { |x| x.report('extract') { 1000.times { require_relative 'lib/rich_text_extraction'; RichTextExtraction.extract('test') } } }"

# Memory profiling
profile-memory:
	@echo "🧠 Running memory profiling..."
	@bundle exec ruby -r memory_profiler -e "MemoryProfiler.report { require_relative 'lib/rich_text_extraction' }"

# =============================================================================
# SHORTCUTS
# =============================================================================

# Common shortcuts
t: test
ta: test-all
q: quick
r: rubocop
rf: rubocop-fix
s: security
c: coverage
d: docs
cl: clean
b: build
i: install-gem

# Development shortcuts
ds: dev-setup
dq: dev-quick
df: dev-full
dc: dev-clean
du: dev-update
dch: dev-check

# CI shortcuts
cp: ci-pipeline
cr: ci-report

# Utility shortcuts
ud: utils-deps
uc: utils-config
h: help 