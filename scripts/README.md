# RichTextExtraction Enhanced Testing Workflow

A comprehensive testing workflow for the RichTextExtraction gem that starts with RuboCop auto-fix and includes advanced features like parallel execution, detailed reporting, and CI/CD integration.

## 🚀 Quick Start

```bash
# Run the complete testing workflow
./scripts/test.sh

# Run with verbose output
VERBOSE=true ./scripts/test.sh

# Run only specific tests
RUN_PERFORMANCE_TESTS=true ./scripts/test.sh
```

## 📋 Features

### Core Testing
- **RuboCop Auto-Fix**: Automatically fixes code style violations
- **Syntax Validation**: Comprehensive Ruby syntax checking
- **Security Audits**: Bundle audit for vulnerability detection
- **RSpec Testing**: Full test suite execution with coverage
- **Gem Operations**: Build and installation testing
- **Documentation**: YARD documentation generation and validation
- **Code Quality**: Unused code detection with Debride
- **Performance Testing**: Benchmark and memory profiling

### Advanced Features
- **Parallel Execution**: Run tests concurrently for faster execution
- **Intelligent Caching**: Cache test results to speed up subsequent runs
- **Detailed Reporting**: JSON and HTML test reports
- **Progress Tracking**: Real-time progress indicators
- **Error Recovery**: Retry failed tests with exponential backoff
- **CI/CD Integration**: Automatic platform detection and optimization
- **Environment Awareness**: Different behavior for dev/CI environments

### Monitoring & Analytics
- **Test Metrics Collection**: Comprehensive data gathering
- **Trend Analysis**: Historical performance tracking
- **Alert System**: Automated notifications for issues
- **Dashboard Generation**: Visual test status overview
- **Continuous Monitoring**: Real-time test health tracking

## 📁 Scripts Overview

### Core Scripts
- **`test.sh`** - Main testing workflow (starts with RuboCop auto-fix)
- **`config.sh`** - Configuration management with validation
- **`advanced.sh`** - Advanced testing utilities and optimizations
- **`monitor.sh`** - Monitoring, analytics, and dashboard generation

### Advanced Scripts Usage

#### Advanced Testing Utilities (`advanced.sh`)
```bash
# Run tests in parallel
./scripts/advanced.sh parallel 8

# Generate comprehensive report
./scripts/advanced.sh report

# Monitor test performance
./scripts/advanced.sh monitor './scripts/test.sh' /tmp/perf.txt

# Find slow tests
./scripts/advanced.sh slow 5

# Optimize test database
./scripts/advanced.sh optimize

# Setup intelligent cache
./scripts/advanced.sh cache

# Watch for changes and test
./scripts/advanced.sh watch 'lib/ spec/' 'make quick'

# Generate missing tests
./scripts/advanced.sh generate
```

#### Monitoring & Analytics (`monitor.sh`)
```bash
# Collect test metrics
./scripts/monitor.sh collect /tmp/metrics.json

# Analyze trends over 7 days
./scripts/monitor.sh trends ./tmp/metrics 7

# Check for alerts
./scripts/monitor.sh alerts /tmp/metrics.json

# Send notification
./scripts/monitor.sh notify "Tests completed successfully" info

# Generate dashboard
./scripts/monitor.sh dashboard ./tmp/metrics ./dashboard.html

# Start continuous monitoring
./scripts/monitor.sh monitor
```

## ⚙️ Configuration

### Environment Variables

The testing workflow is highly configurable through environment variables:

```bash
# Core settings
RUBY_VERSION=3.2
PARALLEL_JOBS=4
COVERAGE_THRESHOLD=80

# Test execution flags
RUN_RUBOCOP=true
RUN_SYNTAX_CHECK=true
RUN_SECURITY_AUDIT=true
RUN_RSPEC_TESTS=true
RUN_COVERAGE=true
RUN_GEM_OPERATIONS=true
RUN_DOCUMENTATION=true
RUN_UNUSED_CODE_CHECK=true
RUN_PERFORMANCE_TESTS=false
RUN_RAILS_INTEGRATION=true

# Behavior flags
VERBOSE=false
CREATE_BACKUP=true
FAIL_ON_SECURITY=false
FAIL_FAST=false
RETRY_FAILED=false
MAX_RETRIES=2

# Output and reporting
GENERATE_REPORTS=true
SAVE_ARTIFACTS=true
UPLOAD_REPORTS=false
REPORT_FORMATS="json,html"

# Performance settings
PERFORMANCE_TIMEOUT=300
MEMORY_LIMIT_MB=512
BENCHMARK_ITERATIONS=1000
BENCHMARK_WARMUP=100

# Rails integration
RAILS_VERSIONS="7.0,7.1"
DATABASE_ADAPTERS="sqlite3,postgresql"

# Cache settings
ENABLE_TEST_CACHE=true
CACHE_DIR="./tmp/test_cache"
CACHE_EXPIRY=24

# External integrations
COVERAGE_SERVICE=""
COVERAGE_TOKEN=""
```

### Configuration File

You can also create a custom configuration file:

```bash
# Create custom config
cp scripts/config.sh scripts/config.local.sh

# Edit your settings
vim scripts/config.local.sh

# Use custom config
source scripts/config.local.sh && ./scripts/test.sh
```

## 🎯 Usage Examples

### Basic Usage

```bash
# Run all tests
./scripts/test.sh

# Run with verbose output
VERBOSE=true ./scripts/test.sh

# Run only code quality checks
RUN_RSPEC_TESTS=false RUN_COVERAGE=false ./scripts/test.sh
```

### Advanced Usage

```bash
# Run with custom parallel jobs
PARALLEL_JOBS=8 ./scripts/test.sh

# Run with strict settings (fail on warnings)
FAIL_ON_LOW_COVERAGE=true FAIL_ON_SECURITY=true ./scripts/test.sh

# Run performance tests only
RUN_RUBOCOP=false RUN_SYNTAX_CHECK=false RUN_RSPEC_TESTS=false \
RUN_PERFORMANCE_TESTS=true ./scripts/test.sh

# Run with retry on failure
RETRY_FAILED=true MAX_RETRIES=3 ./scripts/test.sh

# Run with custom coverage threshold
COVERAGE_THRESHOLD=90 ./scripts/test.sh
```

### Advanced Testing Scenarios

```bash
# Parallel test execution with load balancing
./scripts/advanced.sh parallel 8

# Generate comprehensive test report
./scripts/advanced.sh report

# Monitor test performance in real-time
./scripts/advanced.sh monitor './scripts/test.sh' /tmp/performance.txt

# Find and analyze slow tests
./scripts/advanced.sh slow 10

# Optimize test environment
./scripts/advanced.sh optimize

# Setup intelligent caching for faster subsequent runs
./scripts/advanced.sh cache

# Watch for file changes and run tests automatically
./scripts/advanced.sh watch 'lib/ spec/' 'make quick'

# Generate missing test stubs
GENERATE_MISSING_TESTS=true ./scripts/advanced.sh generate
```

### Monitoring & Analytics

```bash
# Collect comprehensive test metrics
./scripts/monitor.sh collect /tmp/test_metrics.json

# Analyze trends over the last 30 days
./scripts/monitor.sh trends ./tmp/metrics 30

# Check for alerts and send notifications
./scripts/monitor.sh alerts /tmp/metrics.json && \
./scripts/monitor.sh notify "All tests passing" info

# Generate interactive dashboard
./scripts/monitor.sh dashboard ./tmp/metrics ./test_dashboard.html

# Start continuous monitoring with hourly checks
./scripts/monitor.sh monitor
```

### CI/CD Integration

The workflow automatically detects CI platforms and optimizes accordingly:

```yaml
# GitHub Actions example
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
      - run: ./scripts/test.sh
      - run: ./scripts/monitor.sh collect ${{ github.workspace }}/metrics.json
      - run: ./scripts/monitor.sh dashboard ${{ github.workspace }}/metrics ${{ github.workspace }}/dashboard.html
      - uses: actions/upload-artifact@v3
        with:
          name: test-dashboard
          path: dashboard.html
```

### Docker Integration

```dockerfile
# Dockerfile example
FROM ruby:3.2

WORKDIR /app
COPY . .

RUN bundle install
RUN chmod +x scripts/*.sh

# Run tests with monitoring
CMD ["./scripts/test.sh"]
```

## 📊 Test Reports

The workflow generates detailed test reports in multiple formats:

### JSON Report

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "duration": 120,
  "summary": {
    "total": 8,
    "passed": 7,
    "failed": 1,
    "skipped": 0
  },
  "passed_tests": [
    "RuboCop auto-fix",
    "Syntax check",
    "Security audit",
    "RSpec tests",
    "Coverage check",
    "Gem operations",
    "Documentation"
  ],
  "failed_tests": [
    "Unused code check"
  ],
  "configuration": {
    "ruby_version": "3.2",
    "parallel_jobs": 4,
    "coverage_threshold": 80
  }
}
```

### HTML Dashboard

The monitoring script generates an interactive HTML dashboard with:
- Real-time metrics visualization
- Trend analysis charts
- Alert notifications
- System health indicators
- Performance tracking

### Comprehensive Reports

The advanced script generates comprehensive reports including:
- System information
- Test results with detailed output
- Performance metrics
- Coverage analysis
- Security audit results
- Trend analysis

## 🔧 Troubleshooting

### Common Issues

#### RuboCop Violations
```bash
# Check remaining violations
bundle exec rubocop --format simple

# Fix specific violations
bundle exec rubocop -A lib/specific_file.rb
```

#### Coverage Issues
```bash
# Check coverage manually
COVERAGE=true bundle exec rspec --format progress --coverage

# View coverage report
open coverage/index.html
```

#### Performance Test Failures
```bash
# Run performance tests with more iterations
BENCHMARK_ITERATIONS=5000 ./scripts/test.sh

# Check memory usage
bundle exec ruby -r memory_profiler -e "MemoryProfiler.report { require_relative 'lib/rich_text_extraction' }"
```

#### Dependency Issues
```bash
# Update dependencies
bundle update

# Install missing gems
bundle install

# Check gem compatibility
bundle exec gem list
```

### Debug Mode

Enable debug mode for detailed troubleshooting:

```bash
# Enable debug output
VERBOSE=true DEBUG=true ./scripts/test.sh

# Check configuration
source scripts/config.sh && env | grep -E "(RUN_|COVERAGE_|PARALLEL_)"
```

### Cache Management

```bash
# Clear test cache
rm -rf ./tmp/test_cache

# Disable caching
ENABLE_TEST_CACHE=false ./scripts/test.sh

# Check cache status
ls -la ./tmp/test_cache/
```

### Performance Optimization

```bash
# Find slow tests
./scripts/advanced.sh slow 5

# Run tests in parallel
./scripts/advanced.sh parallel 8

# Monitor performance
./scripts/advanced.sh monitor './scripts/test.sh' /tmp/perf.txt

# Optimize test database
./scripts/advanced.sh optimize
```

## 🛠️ Customization

### Adding Custom Tests

Create custom test scripts and integrate them:

```bash
# scripts/custom_tests.sh
#!/bin/bash
source scripts/config.sh

run_custom_tests() {
    print_status "Running custom tests..."
    
    # Your custom test logic here
    if your_custom_test_command; then
        print_success "Custom tests passed"
    else
        print_error "Custom tests failed"
        return 1
    fi
}

# Add to main test script
run_custom_tests
```

### Custom Validators

Add custom validation rules:

```bash
# scripts/custom_validators.sh
#!/bin/bash

validate_custom_rules() {
    print_status "Running custom validations..."
    
    # Check for TODO comments
    local todo_count=$(grep -r "TODO" lib/ | wc -l)
    if [ "$todo_count" -gt 0 ]; then
        print_warning "Found $todo_count TODO comments"
    fi
    
    # Check file sizes
    find lib/ -name "*.rb" -size +100k | while read file; do
        print_warning "Large file detected: $file"
    done
}
```

### Performance Benchmarks

Create custom performance benchmarks:

```ruby
# spec/performance_spec.rb
require 'benchmark'
require 'rich_text_extraction'

RSpec.describe 'Performance' do
  it 'extracts text within performance threshold' do
    text = "Sample text with #hashtag and @mention"
    
    time = Benchmark.realtime do
      1000.times { RichTextExtraction.extract(text) }
    end
    
    expect(time).to be < 1.0  # Should complete in under 1 second
  end
end
```

### Custom Monitoring

Extend the monitoring system:

```bash
# scripts/custom_monitor.sh
#!/bin/bash

custom_metrics() {
    # Collect custom metrics
    local custom_data=$(your_custom_metric_collector)
    
    # Add to metrics JSON
    jq --arg data "$custom_data" '.custom_metrics = $data' metrics.json > metrics_updated.json
    mv metrics_updated.json metrics.json
}
```

## 📈 Performance Optimization

### Parallel Execution

Optimize for your system:

```bash
# For high-end systems
PARALLEL_JOBS=8 ./scripts/test.sh

# For CI environments
PARALLEL_JOBS=2 ./scripts/test.sh

# For memory-constrained systems
PARALLEL_JOBS=1 MEMORY_LIMIT_MB=256 ./scripts/test.sh
```

### Caching Strategy

```bash
# Enable aggressive caching
CACHE_EXPIRY=168  # 1 week

# Cache specific test results
ENABLE_TEST_CACHE=true CACHE_DIR="./.test_cache" ./scripts/test.sh

# Clear cache periodically
find ./.test_cache -type f -mtime +7 -delete
```

### Advanced Optimizations

```bash
# Find and optimize slow tests
./scripts/advanced.sh slow 10

# Run tests in parallel with load balancing
./scripts/advanced.sh parallel 8

# Setup intelligent caching
./scripts/advanced.sh cache

# Optimize test database
./scripts/advanced.sh optimize
```

## 🔒 Security Considerations

### Bundle Audit

```bash
# Run security audit manually
bundle exec bundle audit check --update

# Check specific vulnerabilities
bundle exec bundle audit check --group security
```

### Code Quality

```bash
# Check for security-related issues
bundle exec rubocop --only Security

# Check for potential vulnerabilities
bundle exec brakeman
```

### Monitoring Security

```bash
# Monitor for security alerts
./scripts/monitor.sh alerts /tmp/metrics.json

# Set up security notifications
./scripts/monitor.sh notify "Security vulnerability detected" error
```

## 📚 Integration with Other Tools

### IDE Integration

#### VS Code
```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Run Tests",
      "type": "shell",
      "command": "./scripts/test.sh",
      "group": "test",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      }
    },
    {
      "label": "Generate Dashboard",
      "type": "shell",
      "command": "./scripts/monitor.sh dashboard",
      "group": "test"
    }
  ]
}
```

#### IntelliJ IDEA
```xml
<!-- .idea/runConfigurations/Test_Workflow.xml -->
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Test Workflow" type="BashConfigurationType">
    <option name="scriptPath" value="$PROJECT_DIR$/scripts/test.sh" />
    <option name="scriptParameters" value="" />
  </configuration>
  <configuration default="false" name="Test Monitor" type="BashConfigurationType">
    <option name="scriptPath" value="$PROJECT_DIR$/scripts/monitor.sh" />
    <option name="scriptParameters" value="monitor" />
  </configuration>
</component>
```

### Git Hooks

```bash
# .git/hooks/pre-commit
#!/bin/bash
./scripts/test.sh || exit 1
```

### CI/CD Platforms

#### GitHub Actions
```yaml
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        ruby-version: [3.0, 3.1, 3.2]
    steps:
      - uses: actions/checkout@v3
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby-version }}
      - run: ./scripts/test.sh
      - run: ./scripts/monitor.sh collect ${{ github.workspace }}/metrics.json
      - run: ./scripts/monitor.sh dashboard ${{ github.workspace }}/metrics ${{ github.workspace }}/dashboard.html
      - uses: actions/upload-artifact@v3
        with:
          name: test-dashboard-${{ matrix.ruby-version }}
          path: dashboard.html
```

#### GitLab CI
```yaml
test:
  image: ruby:3.2
  script:
    - bundle install
    - ./scripts/test.sh
    - ./scripts/monitor.sh collect metrics.json
    - ./scripts/monitor.sh dashboard ./metrics dashboard.html
  artifacts:
    reports:
      junit: test_report_*.json
    paths:
      - dashboard.html
```

## 🤝 Contributing

When contributing to the testing workflow:

1. **Follow the existing patterns** in the scripts
2. **Add configuration options** for new features
3. **Update documentation** for any new functionality
4. **Test your changes** thoroughly
5. **Consider backward compatibility**

### Development Workflow

```bash
# Test your changes
./scripts/test.sh

# Run specific tests during development
RUN_RSPEC_TESTS=false ./scripts/test.sh

# Check for regressions
git stash && ./scripts/test.sh && git stash pop

# Generate dashboard for your changes
./scripts/monitor.sh dashboard ./tmp/metrics ./my_changes_dashboard.html
```

## 📄 License

This testing workflow is part of the RichTextExtraction gem and follows the same license terms.

## 🆘 Support

For issues with the testing workflow:

1. Check the troubleshooting section above
2. Review the configuration options
3. Enable verbose mode for detailed output
4. Check the generated test reports
5. Use the monitoring tools to identify issues
6. Open an issue with detailed error information

---

**Happy Testing! 🎉** 