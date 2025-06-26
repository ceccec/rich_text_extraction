#!/bin/bash

# RichTextExtraction Enhanced Configuration
# This file contains all configuration options for the testing workflow

# =============================================================================
# CORE CONFIGURATION
# =============================================================================

# Ruby version to use (for version-specific testing)
RUBY_VERSION=${RUBY_VERSION:-"3.2"}

# Parallel execution settings
PARALLEL_JOBS=${PARALLEL_JOBS:-4}
MAX_PARALLEL_JOBS=${MAX_PARALLEL_JOBS:-8}

# Coverage settings
COVERAGE_THRESHOLD=${COVERAGE_THRESHOLD:-80}
FAIL_ON_LOW_COVERAGE=${FAIL_ON_LOW_COVERAGE:-false}

# =============================================================================
# TEST EXECUTION FLAGS
# =============================================================================

# Enable/disable specific test types
RUN_RUBOCOP=${RUN_RUBOCOP:-true}
RUN_SYNTAX_CHECK=${RUN_SYNTAX_CHECK:-true}
RUN_SECURITY_AUDIT=${RUN_SECURITY_AUDIT:-true}
RUN_RSPEC_TESTS=${RUN_RSPEC_TESTS:-true}
RUN_COVERAGE=${RUN_COVERAGE:-true}
RUN_GEM_OPERATIONS=${RUN_GEM_OPERATIONS:-true}
RUN_DOCUMENTATION=${RUN_DOCUMENTATION:-true}
RUN_UNUSED_CODE_CHECK=${RUN_UNUSED_CODE_CHECK:-true}
RUN_PERFORMANCE_TESTS=${RUN_PERFORMANCE_TESTS:-false}
RUN_RAILS_INTEGRATION=${RUN_RAILS_INTEGRATION:-true}

# =============================================================================
# BEHAVIOR FLAGS
# =============================================================================

# Verbose output
VERBOSE=${VERBOSE:-false}

# Create backups before modifications
CREATE_BACKUP=${CREATE_BACKUP:-true}

# Fail on security vulnerabilities
FAIL_ON_SECURITY=${FAIL_ON_SECURITY:-false}

# Stop on first failure
FAIL_FAST=${FAIL_FAST:-false}

# Retry failed tests
RETRY_FAILED=${RETRY_FAILED:-false}
MAX_RETRIES=${MAX_RETRIES:-2}

# =============================================================================
# OUTPUT AND REPORTING
# =============================================================================

# Generate detailed reports
GENERATE_REPORTS=${GENERATE_REPORTS:-true}

# Save test artifacts
SAVE_ARTIFACTS=${SAVE_ARTIFACTS:-true}

# Upload reports to external service (if configured)
UPLOAD_REPORTS=${UPLOAD_REPORTS:-false}

# Report formats
REPORT_FORMATS=${REPORT_FORMATS:-"json,html"}

# =============================================================================
# PERFORMANCE SETTINGS
# =============================================================================

# Performance test thresholds
PERFORMANCE_TIMEOUT=${PERFORMANCE_TIMEOUT:-300}
MEMORY_LIMIT_MB=${MEMORY_LIMIT_MB:-512}

# Benchmark settings
BENCHMARK_ITERATIONS=${BENCHMARK_ITERATIONS:-1000}
BENCHMARK_WARMUP=${BENCHMARK_WARMUP:-100}

# =============================================================================
# RAILS INTEGRATION SETTINGS
# =============================================================================

# Rails versions to test against
RAILS_VERSIONS=${RAILS_VERSIONS:-"7.0,7.1"}

# Database adapters to test
DATABASE_ADAPTERS=${DATABASE_ADAPTERS:-"sqlite3,postgresql"}

# =============================================================================
# CACHE AND OPTIMIZATION
# =============================================================================

# Enable test caching
ENABLE_TEST_CACHE=${ENABLE_TEST_CACHE:-true}

# Cache directory
CACHE_DIR=${CACHE_DIR:-"./tmp/test_cache"}

# Cache expiration (in hours)
CACHE_EXPIRY=${CACHE_EXPIRY:-24}

# =============================================================================
# EXTERNAL INTEGRATIONS
# =============================================================================

# Code coverage service (e.g., Codecov, Coveralls)
COVERAGE_SERVICE=${COVERAGE_SERVICE:-""}
COVERAGE_TOKEN=${COVERAGE_TOKEN:-""}

# CI/CD platform detection
CI_PLATFORM=${CI_PLATFORM:-""}
if [ -n "${GITHUB_ACTIONS:-}" ]; then
    CI_PLATFORM="github"
elif [ -n "${GITLAB_CI:-}" ]; then
    CI_PLATFORM="gitlab"
elif [ -n "${CIRCLECI:-}" ]; then
    CI_PLATFORM="circleci"
elif [ -n "${TRAVIS:-}" ]; then
    CI_PLATFORM="travis"
fi

# =============================================================================
# ADVANCED SETTINGS
# =============================================================================

# RSpec specific settings
RSPEC_FORMAT=${RSPEC_FORMAT:-"progress"}
RSPEC_OPTIONS=${RSPEC_OPTIONS:-"--format documentation --out /tmp/rspec_results.txt"}

# RuboCop specific settings
RUBOCOP_AUTO_FIX=${RUBOCOP_AUTO_FIX:-true}
RUBOCOP_FAIL_LEVEL=${RUBOCOP_FAIL_LEVEL:-"error"}

# YARD documentation settings
YARD_FAIL_ON_WARNING=${YARD_FAIL_ON_WARNING:-false}
YARD_OPTIONS=${YARD_OPTIONS:-"--fail-on-warning"}

# =============================================================================
# ENVIRONMENT-SPECIFIC OVERRIDES
# =============================================================================

# Development environment overrides
if [ "${RAILS_ENV:-}" = "development" ]; then
    VERBOSE=true
    FAIL_ON_LOW_COVERAGE=false
    RUN_PERFORMANCE_TESTS=false
fi

# CI environment overrides
if [ -n "$CI_PLATFORM" ]; then
    VERBOSE=false
    FAIL_ON_LOW_COVERAGE=true
    FAIL_ON_SECURITY=true
    SAVE_ARTIFACTS=true
    UPLOAD_REPORTS=true
fi

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

# Validate configuration
validate_config() {
    local errors=()
    
    # Check required values
    if [ "$COVERAGE_THRESHOLD" -lt 0 ] || [ "$COVERAGE_THRESHOLD" -gt 100 ]; then
        errors+=("COVERAGE_THRESHOLD must be between 0 and 100")
    fi
    
    if [ "$PARALLEL_JOBS" -lt 1 ] || [ "$PARALLEL_JOBS" -gt "$MAX_PARALLEL_JOBS" ]; then
        errors+=("PARALLEL_JOBS must be between 1 and $MAX_PARALLEL_JOBS")
    fi
    
    if [ "$MAX_RETRIES" -lt 0 ]; then
        errors+=("MAX_RETRIES must be non-negative")
    fi
    
    # Check for conflicting settings
    if [ "$FAIL_FAST" = true ] && [ "$RETRY_FAILED" = true ]; then
        errors+=("FAIL_FAST and RETRY_FAILED cannot both be true")
    fi
    
    # Report errors
    if [ ${#errors[@]} -gt 0 ]; then
        echo "Configuration validation failed:" >&2
        for error in "${errors[@]}"; do
            echo "  - $error" >&2
        done
        return 1
    fi
    
    return 0
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Get configuration value with fallback
get_config() {
    local key="$1"
    local default="$2"
    echo "${!key:-$default}"
}

# Set configuration value
set_config() {
    local key="$1"
    local value="$2"
    export "$key=$value"
}

# Export all configuration for child processes
export_config() {
    # Core configuration
    export RUBY_VERSION PARALLEL_JOBS MAX_PARALLEL_JOBS
    export COVERAGE_THRESHOLD FAIL_ON_LOW_COVERAGE
    
    # Test execution flags
    export RUN_RUBOCOP RUN_SYNTAX_CHECK RUN_SECURITY_AUDIT
    export RUN_RSPEC_TESTS RUN_COVERAGE RUN_GEM_OPERATIONS
    export RUN_DOCUMENTATION RUN_UNUSED_CODE_CHECK
    export RUN_PERFORMANCE_TESTS RUN_RAILS_INTEGRATION
    
    # Behavior flags
    export VERBOSE CREATE_BACKUP FAIL_ON_SECURITY
    export FAIL_FAST RETRY_FAILED MAX_RETRIES
    
    # Output and reporting
    export GENERATE_REPORTS SAVE_ARTIFACTS UPLOAD_REPORTS
    export REPORT_FORMATS
    
    # Performance settings
    export PERFORMANCE_TIMEOUT MEMORY_LIMIT_MB
    export BENCHMARK_ITERATIONS BENCHMARK_WARMUP
    
    # Rails integration settings
    export RAILS_VERSIONS DATABASE_ADAPTERS
    
    # Cache and optimization
    export ENABLE_TEST_CACHE CACHE_DIR CACHE_EXPIRY
    
    # External integrations
    export COVERAGE_SERVICE COVERAGE_TOKEN CI_PLATFORM
    
    # Advanced settings
    export RSPEC_FORMAT RSPEC_OPTIONS
    export RUBOCOP_AUTO_FIX RUBOCOP_FAIL_LEVEL
    export YARD_FAIL_ON_WARNING YARD_OPTIONS
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Validate configuration on load
if ! validate_config; then
    echo "Configuration validation failed. Please check your settings." >&2
    exit 1
fi

# Export configuration for use in other scripts
export_config

# Create cache directory if needed
if [ "$ENABLE_TEST_CACHE" = true ] && [ ! -d "$CACHE_DIR" ]; then
    mkdir -p "$CACHE_DIR"
fi

# =============================================================================
# CONFIGURATION SUMMARY
# =============================================================================

# Print configuration summary (only if VERBOSE is true)
if [ "$VERBOSE" = true ]; then
    echo "Configuration loaded:"
    echo "  Ruby Version: $RUBY_VERSION"
    echo "  Parallel Jobs: $PARALLEL_JOBS"
    echo "  Coverage Threshold: ${COVERAGE_THRESHOLD}%"
    echo "  Verbose Output: $VERBOSE"
    echo "  CI Platform: ${CI_PLATFORM:-none}"
    echo "  Cache Enabled: $ENABLE_TEST_CACHE"
    echo ""
fi 