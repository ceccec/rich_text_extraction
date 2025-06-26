#!/bin/bash

# RichTextExtraction Enhanced Testing Workflow
# This script runs the complete testing suite starting with RuboCop auto-fix

set -euo pipefail  # Exit on any error, undefined vars, pipe failures

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# Initialize variables
START_TIME=$(date +%s)
FAILED_TESTS=()
PASSED_TESTS=()
SKIPPED_TESTS=()
TOTAL_TESTS=0
PARALLEL_JOBS=${PARALLEL_JOBS:-4}

echo "🚀 Starting RichTextExtraction Enhanced Testing Workflow"
echo "======================================================"
echo "Configuration:"
echo "  Ruby Version: ${RUBY_VERSION}"
echo "  Parallel Jobs: ${PARALLEL_JOBS}"
echo "  Coverage Threshold: ${COVERAGE_THRESHOLD}%"
echo "  Verbose: ${VERBOSE}"
echo ""

# Enhanced colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Enhanced output functions
print_header() {
    echo -e "${BOLD}${CYAN}$1${NC}"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    PASSED_TESTS+=("$1")
    ((TOTAL_TESTS++))
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    SKIPPED_TESTS+=("$1")
    ((TOTAL_TESTS++))
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    FAILED_TESTS+=("$1")
    ((TOTAL_TESTS++))
}

print_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\r${CYAN}[%3d%%]${NC} [" $percentage
    printf "%${completed}s" | tr ' ' '█'
    printf "%${remaining}s" | tr ' ' '░'
    printf "] %d/%d" $current $total
}

# Error handling and cleanup
cleanup() {
    local exit_code=$?
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    echo ""
    echo ""
    print_header "Test Summary"
    echo "=============="
    echo "Duration: ${DURATION} seconds"
    echo "Total Tests: ${TOTAL_TESTS}"
    echo "Passed: ${#PASSED_TESTS[@]}"
    echo "Failed: ${#FAILED_TESTS[@]}"
    echo "Skipped: ${#SKIPPED_TESTS[@]}"
    
    if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
        echo ""
        print_error "Failed Tests:"
        for test in "${FAILED_TESTS[@]}"; do
            echo "  - ${test}"
        done
    fi
    
    if [ ${#SKIPPED_TESTS[@]} -gt 0 ]; then
        echo ""
        print_warning "Skipped Tests:"
        for test in "${SKIPPED_TESTS[@]}"; do
            echo "  - ${test}"
        done
    fi
    
    # Generate test report
    generate_test_report
    
    exit $exit_code
}

trap cleanup EXIT

# Check system requirements
check_requirements() {
    print_status "Checking system requirements..."
    
    # Check Ruby version
    if ! command -v ruby >/dev/null 2>&1; then
        print_error "Ruby is not installed"
        exit 1
    fi
    
    # Check Bundler
    if ! command -v bundle >/dev/null 2>&1; then
        print_error "Bundler is not installed"
        exit 1
    fi
    
    # Check if we're in the right directory
    if [ ! -f "rich_text_extraction.gemspec" ]; then
        print_error "Please run this script from the gem root directory"
        exit 1
    fi
    
    # Check available memory
    if command -v free >/dev/null 2>&1; then
        local available_mem=$(free -m | awk 'NR==2{printf "%.0f", $7/1024}')
        if [ "$available_mem" -lt 2 ]; then
            print_warning "Low memory available (${available_mem}GB). Consider closing other applications."
        fi
    fi
    
    print_success "System requirements check passed"
}

# Parallel execution helper
run_parallel() {
    local max_jobs=$1
    shift
    local jobs=()
    
    for cmd in "$@"; do
        if [ ${#jobs[@]} -ge $max_jobs ]; then
            wait "${jobs[0]}"
            jobs=("${jobs[@]:1}")
        fi
        
        eval "$cmd" &
        jobs+=($!)
    done
    
    wait "${jobs[@]}"
}

# Enhanced dependency installation
install_dependencies() {
    print_status "Installing dependencies..."
    
    # Check if Gemfile.lock exists and is recent
    if [ -f "Gemfile.lock" ]; then
        local lock_age=$(( $(date +%s) - $(stat -f %m Gemfile.lock 2>/dev/null || echo 0) ))
        if [ $lock_age -gt 86400 ]; then  # 24 hours
            print_warning "Gemfile.lock is older than 24 hours, updating dependencies..."
            bundle update
        else
            bundle install
        fi
    else
        bundle install
    fi
    
    # Install development gems if needed
    if [ "$RUN_PERFORMANCE_TESTS" = true ] && ! gem list | grep -q "benchmark-ips"; then
        print_status "Installing performance testing gems..."
        gem install benchmark-ips memory_profiler
    fi
    
    print_success "Dependencies installed"
}

# Enhanced RuboCop execution
run_rubocop() {
    print_status "Running RuboCop with auto-fix..."
    
    # Create backup of changed files
    if [ "$CREATE_BACKUP" = true ]; then
        print_status "Creating backup of modified files..."
        git diff --name-only | grep '\.rb$' | xargs -I {} cp {} {}.backup 2>/dev/null || true
    fi
    
    # Run RuboCop with auto-fix
    if bundle exec rubocop -A; then
        print_success "RuboCop auto-fix completed"
    else
        print_warning "RuboCop auto-fix had issues"
    fi
    
    # Check for remaining violations
    print_status "Checking for remaining RuboCop violations..."
    local violations=$(bundle exec rubocop --format simple | grep -c "offense" || echo "0")
    
    if [ "$violations" -eq 0 ]; then
        print_success "No RuboCop violations found"
    else
        print_warning "Found $violations RuboCop violations - please fix manually"
        if [ "$VERBOSE" = true ]; then
            bundle exec rubocop --format simple
        fi
    fi
}

# Enhanced syntax check
run_syntax_check() {
    print_status "Running syntax check..."
    
    local syntax_errors=0
    local files_checked=0
    
    while IFS= read -r -d '' file; do
        if ruby -c "$file" >/dev/null 2>&1; then
            ((files_checked++))
        else
            print_error "Syntax error in $file"
            ((syntax_errors++))
        fi
    done < <(find lib/ -name "*.rb" -print0)
    
    if [ $syntax_errors -eq 0 ]; then
        print_success "Syntax check passed ($files_checked files checked)"
    else
        print_error "Syntax check failed ($syntax_errors errors found)"
        return 1
    fi
}

# Enhanced security audit
run_security_audit() {
    if [ "$RUN_SECURITY_AUDIT" = true ]; then
        print_status "Running security audit..."
        
        if bundle exec bundle audit check --update; then
            print_success "Security audit passed"
        else
            print_warning "Security vulnerabilities found"
            if [ "$FAIL_ON_SECURITY" = true ]; then
                return 1
            fi
        fi
    else
        print_warning "Security audit skipped (disabled in config)"
    fi
}

# Enhanced RSpec execution
run_rspec_tests() {
    print_status "Running RSpec tests..."
    
    # Run tests with progress tracking
    if bundle exec rspec --format progress --format documentation --out /tmp/rspec_results.txt; then
        print_success "RSpec tests passed"
        
        # Extract test statistics
        local total_tests=$(grep -c "example" /tmp/rspec_results.txt || echo "0")
        local failures=$(grep -c "FAILED" /tmp/rspec_results.txt || echo "0")
        
        echo "  Total examples: $total_tests"
        echo "  Failures: $failures"
    else
        print_error "RSpec tests failed"
        if [ "$VERBOSE" = true ]; then
            cat /tmp/rspec_results.txt
        fi
        return 1
    fi
}

# Enhanced coverage check
run_coverage_check() {
    if [ "$RUN_COVERAGE" = true ]; then
        print_status "Running tests with coverage..."
        
        COVERAGE=true bundle exec rspec --format progress --coverage
        
        # Check coverage threshold
        if [ -f "coverage/.resultset.json" ]; then
            local coverage_percent=$(bundle exec rake coverage:report 2>/dev/null | grep -o '[0-9.]*%' | head -1 | sed 's/%//' || echo "0")
            
            if (( $(echo "$coverage_percent >= $COVERAGE_THRESHOLD" | bc -l) )); then
                print_success "Coverage threshold met ($coverage_percent% >= ${COVERAGE_THRESHOLD}%)"
            else
                print_warning "Coverage below threshold ($coverage_percent% < ${COVERAGE_THRESHOLD}%)"
                if [ "$FAIL_ON_LOW_COVERAGE" = true ]; then
                    return 1
                fi
            fi
        fi
    else
        print_warning "Coverage check skipped (disabled in config)"
    fi
}

# Enhanced gem operations
run_gem_operations() {
    print_status "Building gem..."
    if bundle exec rake build; then
        print_success "Gem build successful"
    else
        print_error "Gem build failed"
        return 1
    fi
    
    print_status "Testing gem installation..."
    if bundle exec rake install; then
        print_success "Gem installation test passed"
    else
        print_error "Gem installation test failed"
        return 1
    fi
}

# Enhanced documentation check
run_documentation_check() {
    if [ "$RUN_DOCUMENTATION" = true ]; then
        print_status "Generating documentation..."
        
        if bundle exec yard doc --fail-on-warning; then
            print_success "Documentation generated successfully"
            
            # Check documentation coverage
            local undocumented=$(bundle exec yard stats --list-undoc | wc -l)
            if [ "$undocumented" -gt 0 ]; then
                print_warning "Found $undocumented undocumented methods"
                if [ "$VERBOSE" = true ]; then
                    bundle exec yard stats --list-undoc
                fi
            fi
        else
            print_warning "Documentation generation had warnings"
        fi
    else
        print_warning "Documentation check skipped (disabled in config)"
    fi
}

# Enhanced unused code check
run_unused_code_check() {
    print_status "Checking for unused code..."
    
    if command -v debride >/dev/null 2>&1; then
        local unused_count=$(bundle exec debride lib/ | wc -l)
        if [ "$unused_count" -gt 0 ]; then
            print_warning "Found $unused_count potentially unused methods"
            if [ "$VERBOSE" = true ]; then
                bundle exec debride lib/
            fi
        else
            print_success "No unused code detected"
        fi
    else
        print_warning "Debride not installed - skipping unused code check"
    fi
}

# Enhanced performance tests
run_performance_tests() {
    if [ "$RUN_PERFORMANCE_TESTS" = true ]; then
        print_status "Running performance tests..."
        
        if [ -f "spec/performance_spec.rb" ]; then
            bundle exec rspec spec/performance_spec.rb
            print_success "Performance tests completed"
        else
            print_warning "No performance tests found"
        fi
    else
        print_warning "Performance tests skipped (disabled in config)"
    fi
}

# Generate test report
generate_test_report() {
    local report_file="test_report_$(date +%Y%m%d_%H%M%S).json"
    
    cat > "$report_file" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "duration": $DURATION,
  "summary": {
    "total": $TOTAL_TESTS,
    "passed": ${#PASSED_TESTS[@]},
    "failed": ${#FAILED_TESTS[@]},
    "skipped": ${#SKIPPED_TESTS[@]}
  },
  "passed_tests": $(printf '%s\n' "${PASSED_TESTS[@]}" | jq -R . | jq -s .),
  "failed_tests": $(printf '%s\n' "${FAILED_TESTS[@]}" | jq -R . | jq -s .),
  "skipped_tests": $(printf '%s\n' "${SKIPPED_TESTS[@]}" | jq -R . | jq -s .),
  "configuration": {
    "ruby_version": "$RUBY_VERSION",
    "parallel_jobs": $PARALLEL_JOBS,
    "coverage_threshold": $COVERAGE_THRESHOLD
  }
}
EOF
    
    print_status "Test report generated: $report_file"
}

# Main execution
main() {
    check_requirements
    install_dependencies
    
    # Run tests in sequence (some tests depend on others)
    run_rubocop
    run_syntax_check
    run_security_audit
    run_rspec_tests
    run_coverage_check
    run_gem_operations
    run_documentation_check
    run_unused_code_check
    run_performance_tests
    
    print_header "Testing workflow completed successfully!"
}

# Run main function
main "$@" 