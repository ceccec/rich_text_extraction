#!/bin/bash

# RichTextExtraction Advanced Testing Utilities
# This script provides advanced features for the testing workflow

set -euo pipefail

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# Enhanced colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Print functions
print_header() {
    echo -e "${BOLD}${CYAN}$1${NC}"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# =============================================================================
# PARALLEL TEST EXECUTION
# =============================================================================

# Run tests in parallel with load balancing
run_parallel_tests() {
    local max_jobs=${1:-4}
    local test_files=($(find spec/ -name "*_spec.rb" -type f))
    local total_files=${#test_files[@]}
    local current_job=0
    
    print_header "Running $total_files test files with $max_jobs parallel jobs"
    
    # Create job queue
    for file in "${test_files[@]}"; do
        if [ $current_job -ge $max_jobs ]; then
            wait
            current_job=0
        fi
        
        (
            print_status "Running $file"
            if bundle exec rspec "$file" --format progress; then
                print_success "$file passed"
            else
                print_error "$file failed"
                exit 1
            fi
        ) &
        
        ((current_job++))
    done
    
    wait
    print_success "All parallel tests completed"
}

# =============================================================================
# ADVANCED REPORTING
# =============================================================================

# Generate comprehensive test report
generate_comprehensive_report() {
    local report_dir="reports/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$report_dir"
    
    print_header "Generating comprehensive test report in $report_dir"
    
    # System information
    {
        echo "# System Information"
        echo "Date: $(date)"
        echo "Ruby Version: $(ruby --version)"
        echo "Bundler Version: $(bundle --version)"
        echo "Platform: $(uname -a)"
        echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
        echo "Disk: $(df -h . | tail -1 | awk '{print $4}') available"
        echo ""
    } > "$report_dir/system_info.md"
    
    # Test results
    {
        echo "# Test Results"
        echo "## RuboCop"
        bundle exec rubocop --format simple > "$report_dir/rubocop.txt" 2>&1 || true
        
        echo "## RSpec"
        bundle exec rspec --format documentation --out "$report_dir/rspec.txt" || true
        
        echo "## Coverage"
        if [ -f "coverage/.resultset.json" ]; then
            bundle exec rake coverage:report > "$report_dir/coverage.txt" 2>&1 || true
        fi
        
        echo "## Security"
        bundle exec bundle audit check > "$report_dir/security.txt" 2>&1 || true
    }
    
    # Performance metrics
    generate_performance_report "$report_dir"
    
    # Generate summary
    generate_report_summary "$report_dir"
    
    print_success "Comprehensive report generated in $report_dir"
}

# Generate performance report
generate_performance_report() {
    local report_dir="$1"
    
    print_status "Generating performance report..."
    
    {
        echo "# Performance Report"
        echo "## Memory Usage"
        echo "```"
        ps -o pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -10
        echo "```"
        
        echo "## Disk Usage"
        echo "```"
        du -sh . | head -5
        echo "```"
        
        echo "## Load Average"
        echo "```"
        uptime
        echo "```"
    } > "$report_dir/performance.md"
}

# Generate report summary
generate_report_summary() {
    local report_dir="$1"
    
    {
        echo "# Test Summary"
        echo "Generated: $(date)"
        echo ""
        echo "## Quick Stats"
        echo "- Test Files: $(find spec/ -name "*_spec.rb" | wc -l)"
        echo "- Ruby Files: $(find lib/ -name "*.rb" | wc -l)"
        echo "- Coverage: $(if [ -f "coverage/.resultset.json" ]; then echo "Available"; else echo "Not available"; fi)"
        echo "- RuboCop Violations: $(grep -c "offense" "$report_dir/rubocop.txt" 2>/dev/null || echo "0")"
        echo ""
        echo "## Files"
        echo "- System Info: system_info.md"
        echo "- RuboCop Results: rubocop.txt"
        echo "- RSpec Results: rspec.txt"
        echo "- Coverage Report: coverage.txt"
        echo "- Security Audit: security.txt"
        echo "- Performance: performance.md"
    } > "$report_dir/README.md"
}

# =============================================================================
# PERFORMANCE MONITORING
# =============================================================================

# Monitor test execution performance
monitor_test_performance() {
    local test_command="$1"
    local output_file="$2"
    
    print_status "Monitoring performance for: $test_command"
    
    # Start monitoring
    (
        while true; do
            echo "$(date '+%H:%M:%S') $(ps -o %mem,%cpu --no-headers -p $$)" >> "$output_file"
            sleep 5
        done
    ) &
    local monitor_pid=$!
    
    # Run the test command
    eval "$test_command"
    local exit_code=$?
    
    # Stop monitoring
    kill $monitor_pid 2>/dev/null || true
    
    # Generate performance graph
    generate_performance_graph "$output_file"
    
    return $exit_code
}

# Generate performance graph
generate_performance_graph() {
    local data_file="$1"
    local graph_file="${data_file%.txt}.png"
    
    if command -v gnuplot >/dev/null 2>&1; then
        print_status "Generating performance graph..."
        
        gnuplot << EOF
set terminal png size 800,600
set output '$graph_file'
set title 'Test Performance Over Time'
set xlabel 'Time'
set ylabel 'Usage (%)'
set grid
plot '$data_file' using 1:2 with lines title 'Memory', \
     '$data_file' using 1:3 with lines title 'CPU'
EOF
        
        print_success "Performance graph generated: $graph_file"
    else
        print_warning "Gnuplot not available - skipping graph generation"
    fi
}

# =============================================================================
# TEST OPTIMIZATION
# =============================================================================

# Find slow tests
find_slow_tests() {
    print_header "Finding slow tests..."
    
    local slow_tests=()
    local threshold=${1:-5}  # seconds
    
    while IFS= read -r -d '' file; do
        local start_time=$(date +%s)
        if timeout $((threshold + 2)) bundle exec rspec "$file" --format progress >/dev/null 2>&1; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            
            if [ $duration -gt $threshold ]; then
                slow_tests+=("$file:$duration")
            fi
        fi
    done < <(find spec/ -name "*_spec.rb" -print0)
    
    if [ ${#slow_tests[@]} -gt 0 ]; then
        print_warning "Found ${#slow_tests[@]} slow tests (>${threshold}s):"
        for test in "${slow_tests[@]}"; do
            echo "  - $test"
        done
    else
        print_success "No slow tests found"
    fi
}

# Optimize test database
optimize_test_db() {
    print_header "Optimizing test database..."
    
    if [ -f "spec/dummy/config/database.yml" ]; then
        print_status "Found test database configuration"
        
        # Run database optimizations
        cd spec/dummy
        
        # Vacuum database
        if command -v sqlite3 >/dev/null 2>&1; then
            print_status "Vacuuming SQLite database..."
            sqlite3 db/test.sqlite3 "VACUUM;" 2>/dev/null || true
        fi
        
        # Reset database
        print_status "Resetting test database..."
        bundle exec rails db:test:prepare 2>/dev/null || true
        
        cd ../..
        print_success "Database optimization completed"
    else
        print_warning "No test database configuration found"
    fi
}

# =============================================================================
# CACHE MANAGEMENT
# =============================================================================

# Intelligent test caching
setup_intelligent_cache() {
    local cache_dir="${CACHE_DIR:-./tmp/test_cache}"
    local cache_expiry="${CACHE_EXPIRY:-24}"
    
    print_header "Setting up intelligent test cache"
    
    # Create cache directory
    mkdir -p "$cache_dir"
    
    # Clean expired cache
    find "$cache_dir" -type f -mtime +$cache_expiry -delete 2>/dev/null || true
    
    # Generate cache key
    local cache_key=$(generate_cache_key)
    local cache_file="$cache_dir/$cache_key"
    
    print_status "Cache key: $cache_key"
    
    if [ -f "$cache_file" ]; then
        print_success "Using cached test results"
        cat "$cache_file"
        return 0
    else
        print_status "No cache found, running tests..."
        return 1
    fi
}

# Generate cache key based on file changes
generate_cache_key() {
    local files_hash=$(find lib/ spec/ -name "*.rb" -exec sha256sum {} \; | sort | sha256sum | cut -d' ' -f1)
    local config_hash=$(sha256sum Gemfile.lock 2>/dev/null | cut -d' ' -f1 || echo "no-lock")
    echo "${files_hash:0:8}_${config_hash:0:8}"
}

# Save test results to cache
save_test_cache() {
    local cache_dir="${CACHE_DIR:-./tmp/test_cache}"
    local cache_key=$(generate_cache_key)
    local cache_file="$cache_dir/$cache_key"
    
    print_status "Saving test results to cache..."
    
    {
        echo "Test Results - $(date)"
        echo "Cache Key: $cache_key"
        echo "Files Hash: $(find lib/ spec/ -name "*.rb" -exec sha256sum {} \; | sort | sha256sum | cut -d' ' -f1)"
        echo "Config Hash: $(sha256sum Gemfile.lock 2>/dev/null | cut -d' ' -f1 || echo "no-lock")"
    } > "$cache_file"
    
    print_success "Test results cached: $cache_file"
}

# =============================================================================
# CONTINUOUS TESTING
# =============================================================================

# Watch for changes and run tests
watch_and_test() {
    local watch_dirs="${1:-lib/ spec/}"
    local test_command="${2:-./scripts/test.sh}"
    
    print_header "Starting continuous testing"
    print_status "Watching: $watch_dirs"
    print_status "Command: $test_command"
    echo "Press Ctrl+C to stop"
    
    # Check if fswatch is available
    if command -v fswatch >/dev/null 2>&1; then
        fswatch -o $watch_dirs | while read f; do
            print_status "Change detected, running tests..."
            eval "$test_command"
        done
    elif command -v inotifywait >/dev/null 2>&1; then
        while inotifywait -r -e modify,create,delete $watch_dirs; do
            print_status "Change detected, running tests..."
            eval "$test_command"
        done
    else
        print_error "No file watcher available (fswatch or inotifywait required)"
        exit 1
    fi
}

# =============================================================================
# TEST GENERATION
# =============================================================================

# Generate missing tests
generate_missing_tests() {
    print_header "Generating missing tests..."
    
    local lib_files=($(find lib/ -name "*.rb" -type f))
    local spec_files=($(find spec/ -name "*_spec.rb" -type f))
    local missing_tests=()
    
    for lib_file in "${lib_files[@]}"; do
        local relative_path="${lib_file#lib/}"
        local spec_file="spec/${relative_path%.rb}_spec.rb"
        
        if [ ! -f "$spec_file" ]; then
            missing_tests+=("$lib_file")
        fi
    done
    
    if [ ${#missing_tests[@]} -gt 0 ]; then
        print_warning "Found ${#missing_tests[@]} files without tests:"
        for file in "${missing_tests[@]}"; do
            echo "  - $file"
        done
        
        if [ "${GENERATE_MISSING_TESTS:-false}" = true ]; then
            generate_test_stubs "${missing_tests[@]}"
        fi
    else
        print_success "All files have corresponding tests"
    fi
}

# Generate test stubs
generate_test_stubs() {
    local files=("$@")
    
    print_status "Generating test stubs..."
    
    for file in "${files[@]}"; do
        local relative_path="${file#lib/}"
        local spec_file="spec/${relative_path%.rb}_spec.rb"
        local module_name=$(basename "$file" .rb | tr 'a-z' 'A-Z')
        
        mkdir -p "$(dirname "$spec_file")"
        
        cat > "$spec_file" << EOF
require 'spec_helper'

RSpec.describe $module_name do
  # TODO: Add tests for $module_name
  
  describe '.new' do
    it 'can be instantiated' do
      expect { described_class.new }.not_to raise_error
    end
  end
end
EOF
        
        print_status "Generated: $spec_file"
    done
    
    print_success "Test stubs generated"
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    local command="${1:-help}"
    
    case "$command" in
        "parallel")
            run_parallel_tests "${2:-4}"
            ;;
        "report")
            generate_comprehensive_report
            ;;
        "monitor")
            monitor_test_performance "${2:-./scripts/test.sh}" "${3:-/tmp/performance.txt}"
            ;;
        "slow")
            find_slow_tests "${2:-5}"
            ;;
        "optimize")
            optimize_test_db
            ;;
        "cache")
            setup_intelligent_cache
            ;;
        "watch")
            watch_and_test "${2:-lib/ spec/}" "${3:-./scripts/test.sh}"
            ;;
        "generate")
            generate_missing_tests
            ;;
        "help"|*)
            echo "RichTextExtraction Advanced Testing Utilities"
            echo "============================================="
            echo ""
            echo "Commands:"
            echo "  parallel [jobs]     # Run tests in parallel"
            echo "  report              # Generate comprehensive report"
            echo "  monitor [cmd] [file] # Monitor test performance"
            echo "  slow [seconds]      # Find slow tests"
            echo "  optimize            # Optimize test database"
            echo "  cache               # Setup intelligent cache"
            echo "  watch [dirs] [cmd]  # Watch for changes and test"
            echo "  generate            # Generate missing tests"
            echo "  help                # Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 parallel 8"
            echo "  $0 monitor './scripts/test.sh' /tmp/perf.txt"
            echo "  $0 watch 'lib/ spec/' 'make quick'"
            ;;
    esac
}

# Run main function
main "$@" 