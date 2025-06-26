# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'
require 'rubocop/rake_task'

# Load configuration
load File.expand_path('scripts/config.sh', __dir__) if File.exist?(File.expand_path('scripts/config.sh', __dir__))

# =============================================================================
# CORE TASKS
# =============================================================================

namespace :test do
  desc 'Run complete testing workflow (RuboCop auto-fix + all tests)'
  task all: %i[rubocop_fix syntax security rspec coverage gem_operations docs unused] do
    puts '🎉 Complete testing workflow finished!'
  end

  desc 'Run RuboCop with auto-fix (starting point)'
  task :rubocop_fix do
    puts '🔧 Running RuboCop with auto-fix...'
    system('bundle exec rubocop -A') or raise 'RuboCop auto-fix failed'
    puts '✅ RuboCop auto-fix completed'
  end

  desc 'Run RuboCop check (without auto-fix)'
  task :rubocop do
    puts '🔍 Running RuboCop check...'
    system('bundle exec rubocop') or raise 'RuboCop check failed'
    puts '✅ RuboCop check passed'
  end

  desc 'Run syntax check on all Ruby files'
  task :syntax do
    puts '🔍 Running syntax check...'
    failed = false
    Dir.glob('lib/**/*.rb').each do |file|
      unless system("ruby -c #{file} > /dev/null 2>&1")
        puts "❌ Syntax error in #{file}"
        failed = true
      end
    end
    raise 'Syntax check failed' if failed

    puts '✅ Syntax check passed'
  end

  desc 'Run security audit'
  task :security do
    puts '🔒 Running security audit...'
    if system('bundle exec bundle audit check --update')
      puts '✅ Security audit passed'
    else
      puts '⚠️  Security vulnerabilities found'
      raise 'Security audit failed' if ENV['FAIL_ON_SECURITY'] == 'true'
    end
  end

  desc 'Run RSpec tests'
  RSpec::Core::RakeTask.new(:rspec) do |t|
    t.rspec_opts = '--format progress'
    t.pattern = 'spec/**/*_spec.rb'
  end

  desc 'Run RSpec tests with coverage'
  task :coverage do
    puts '📊 Running tests with coverage...'
    ENV['COVERAGE'] = 'true'
    Rake::Task['test:rspec'].invoke

    # Check coverage threshold
    if File.exist?('coverage/.resultset.json')
      coverage_percent = `bundle exec rake coverage:report 2>/dev/null | grep -o '[0-9.]*%' | head -1 | sed 's/%//'`.strip.to_f
      threshold = (ENV['COVERAGE_THRESHOLD'] || '80').to_f

      if coverage_percent >= threshold
        puts "✅ Coverage threshold met (#{coverage_percent}% >= #{threshold}%)"
      else
        puts "⚠️  Coverage below threshold (#{coverage_percent}% < #{threshold}%)"
        raise 'Coverage below threshold' if ENV['FAIL_ON_LOW_COVERAGE'] == 'true'
      end
    end
  end

  desc 'Test gem build and installation'
  task :gem_operations do
    puts '📦 Testing gem operations...'

    # Build gem
    puts '  Building gem...'
    Rake::Task['build'].invoke

    # Test installation
    puts '  Testing installation...'
    Rake::Task['install'].invoke

    puts '✅ Gem operations completed'
  end

  desc 'Generate and validate documentation'
  task :docs do
    puts '📚 Generating documentation...'
    YARD::Rake::YardocTask.new do |t|
      t.files = ['lib/**/*.rb', 'README.md']
      t.options = ['--fail-on-warning']
    end

    # Check documentation coverage
    undocumented = `bundle exec yard stats --list-undoc 2>/dev/null | wc -l`.strip.to_i
    if undocumented.positive?
      puts "⚠️  Found #{undocumented} undocumented methods"
    else
      puts '✅ Documentation coverage complete'
    end
  end

  desc 'Check for unused code'
  task :unused do
    puts '🔍 Checking for unused code...'
    if system('which debride > /dev/null 2>&1')
      unused_count = `bundle exec debride lib/ 2>/dev/null | wc -l`.strip.to_i
      if unused_count.positive?
        puts "⚠️  Found #{unused_count} potentially unused methods"
        system('bundle exec debride lib/') if ENV['VERBOSE'] == 'true'
      else
        puts '✅ No unused code detected'
      end
    else
      puts '⚠️  Debride not installed - skipping unused code check'
    end
  end

  desc 'Run performance tests'
  task :performance do
    puts '⚡ Running performance tests...'
    if File.exist?('spec/performance_spec.rb')
      system('bundle exec rspec spec/performance_spec.rb') or raise 'Performance tests failed'
      puts '✅ Performance tests completed'
    else
      puts '⚠️  No performance tests found'
    end
  end

  desc 'Run Rails integration tests'
  task :rails_integration do
    puts '🚂 Running Rails integration tests...'
    if File.exist?('spec/rails_integration_spec.rb')
      system('bundle exec rspec spec/rails_integration_spec.rb') or raise 'Rails integration tests failed'
      puts '✅ Rails integration tests completed'
    else
      puts '⚠️  No Rails integration tests found'
    end
  end
end

# =============================================================================
# DEVELOPMENT TASKS
# =============================================================================

namespace :dev do
  desc 'Setup development environment'
  task :setup do
    puts '🔧 Setting up development environment...'

    # Install dependencies
    system('bundle install') or raise 'Bundle install failed'

    # Setup git hooks
    if File.exist?('.git')
      hook_content = "#!/bin/bash\n./scripts/test.sh || exit 1\n"
      File.write('.git/hooks/pre-commit', hook_content)
      File.chmod(0o755, '.git/hooks/pre-commit')
      puts '✅ Git hooks configured'
    end

    # Create necessary directories
    Dir.mkdir('tmp') unless Dir.exist?('tmp')
    Dir.mkdir('log') unless Dir.exist?('log')

    puts '✅ Development environment setup complete'
  end

  desc 'Quick development test (RuboCop + RSpec)'
  task quick: %i[rubocop_fix rspec] do
    puts '✅ Quick test completed'
  end

  desc 'Full development test (all tests except performance)'
  task full: %i[rubocop_fix syntax security rspec coverage gem_operations docs unused] do
    puts '✅ Full development test completed'
  end

  desc 'Clean development artifacts'
  task :clean do
    puts '🧹 Cleaning development artifacts...'

    # Remove build artifacts
    FileUtils.rm_rf('pkg')
    FileUtils.rm_rf('tmp')
    FileUtils.rm_rf('coverage')
    FileUtils.rm_rf('doc')

    # Remove backup files
    Dir.glob('**/*.backup').each { |f| File.delete(f) }
    Dir.glob('**/*.orig').each { |f| File.delete(f) }

    puts '✅ Cleanup completed'
  end

  desc 'Update dependencies'
  task :update do
    puts '📦 Updating dependencies...'
    system('bundle update') or raise 'Bundle update failed'
    puts '✅ Dependencies updated'
  end

  desc 'Check development environment'
  task :check do
    puts '🔍 Checking development environment...'

    # Check Ruby version
    ruby_version = RUBY_VERSION
    puts "  Ruby version: #{ruby_version}"

    # Check Bundler
    if system('which bundle > /dev/null 2>&1')
      puts '  ✅ Bundler installed'
    else
      puts '  ❌ Bundler not installed'
    end

    # Check required gems
    required_gems = %w[rspec rubocop yard debride]
    required_gems.each do |gem|
      if system("bundle exec gem list #{gem} > /dev/null 2>&1")
        puts "  ✅ #{gem} available"
      else
        puts "  ❌ #{gem} not available"
      end
    end

    # Check file structure
    required_files = %w[lib/rich_text_extraction.rb rich_text_extraction.gemspec]
    required_files.each do |file|
      if File.exist?(file)
        puts "  ✅ #{file} exists"
      else
        puts "  ❌ #{file} missing"
      end
    end

    puts '✅ Environment check completed'
  end
end

# =============================================================================
# CI/CD TASKS
# =============================================================================

namespace :ci do
  desc 'Run CI pipeline (all tests with strict settings)'
  task :pipeline do
    puts '🚀 Running CI pipeline...'

    # Set strict environment
    ENV['FAIL_ON_SECURITY'] = 'true'
    ENV['FAIL_ON_LOW_COVERAGE'] = 'true'
    ENV['VERBOSE'] = 'false'

    # Run all tests
    Rake::Task['test:all'].invoke
    Rake::Task['test:performance'].invoke
    Rake::Task['test:rails_integration'].invoke

    puts '✅ CI pipeline completed'
  end

  desc 'Generate CI report'
  task :report do
    puts '📊 Generating CI report...'

    report = {
      timestamp: Time.now.utc.iso8601,
      ruby_version: RUBY_VERSION,
      rails_version: defined?(Rails) ? Rails.version : 'N/A',
      tests: {}
    }

    # Collect test results
    %w[rubocop syntax security rspec coverage docs unused].each do |test|
      Rake::Task["test:#{test}"].invoke
      report[:tests][test] = { status: 'passed' }
    rescue StandardError => e
      report[:tests][test] = { status: 'failed', error: e.message }
    end

    # Write report
    File.write('ci_report.json', JSON.pretty_generate(report))
    puts '✅ CI report generated: ci_report.json'
  end

  desc 'Upload coverage to external service'
  task :upload_coverage do
    puts '📤 Uploading coverage...'

    service = ENV['COVERAGE_SERVICE']
    token = ENV['COVERAGE_TOKEN']

    if service && token
      case service.downcase
      when 'codecov'
        system("bash <(curl -s https://codecov.io/bash) -t #{token}")
      when 'coveralls'
        system('bundle exec coveralls')
      else
        puts "⚠️  Unknown coverage service: #{service}"
      end
    else
      puts '⚠️  Coverage service not configured'
    end
  end
end

# =============================================================================
# UTILITY TASKS
# =============================================================================

namespace :utils do
  desc 'Show task dependencies'
  task :deps do
    puts '📋 Task dependencies:'
    puts '  test:all'
    puts '    ├── test:rubocop_fix'
    puts '    ├── test:syntax'
    puts '    ├── test:security'
    puts '    ├── test:rspec'
    puts '    ├── test:coverage'
    puts '    ├── test:gem_operations'
    puts '    ├── test:docs'
    puts '    └── test:unused'
    puts ''
    puts '  dev:full'
    puts '    ├── test:rubocop_fix'
    puts '    ├── test:syntax'
    puts '    ├── test:security'
    puts '    ├── test:rspec'
    puts '    ├── test:coverage'
    puts '    ├── test:gem_operations'
    puts '    ├── test:docs'
    puts '    └── test:unused'
  end

  desc 'Show configuration'
  task :config do
    puts '⚙️  Current configuration:'
    puts "  Ruby Version: #{RUBY_VERSION}"
    puts "  Coverage Threshold: #{ENV['COVERAGE_THRESHOLD'] || '80'}%"
    puts "  Fail on Security: #{ENV['FAIL_ON_SECURITY'] || 'false'}"
    puts "  Fail on Low Coverage: #{ENV['FAIL_ON_LOW_COVERAGE'] || 'false'}"
    puts "  Verbose: #{ENV['VERBOSE'] || 'false'}"
  end

  desc 'Show help'
  task :help do
    puts '🚀 RichTextExtraction Testing Workflow'
    puts '======================================'
    puts ''
    puts 'Core Tasks:'
    puts '  rake test:all              # Run complete testing workflow'
    puts '  rake test:rubocop_fix      # Run RuboCop with auto-fix'
    puts '  rake test:rspec            # Run RSpec tests'
    puts '  rake test:coverage         # Run tests with coverage'
    puts ''
    puts 'Development Tasks:'
    puts '  rake dev:setup             # Setup development environment'
    puts '  rake dev:quick             # Quick test (RuboCop + RSpec)'
    puts '  rake dev:full              # Full development test'
    puts '  rake dev:clean             # Clean development artifacts'
    puts ''
    puts 'CI/CD Tasks:'
    puts '  rake ci:pipeline           # Run CI pipeline'
    puts '  rake ci:report             # Generate CI report'
    puts ''
    puts 'Utility Tasks:'
    puts '  rake utils:deps            # Show task dependencies'
    puts '  rake utils:config          # Show configuration'
    puts '  rake utils:help            # Show this help'
    puts ''
    puts 'Environment Variables:'
    puts '  COVERAGE_THRESHOLD=90      # Set coverage threshold'
    puts '  FAIL_ON_SECURITY=true      # Fail on security issues'
    puts '  VERBOSE=true               # Enable verbose output'
  end
end

# =============================================================================
# DEFAULT TASKS
# =============================================================================

# Default task
task default: :help

# Help task alias
task help: 'utils:help'

# Test task alias
task test: 'test:all'

# =============================================================================
# RUBOCOP TASKS
# =============================================================================

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
  t.fail_on_error = false
end

RuboCop::RakeTask.new(:rubocop_fix) do |t|
  t.options = ['-A']
  t.fail_on_error = false
end

# =============================================================================
# YARD TASKS
# =============================================================================

YARD::Rake::YardocTask.new(:docs) do |t|
  t.files = ['lib/**/*.rb', 'README.md']
  t.options = ['--fail-on-warning']
end

# =============================================================================
# COVERAGE TASKS
# =============================================================================

namespace :coverage do
  desc 'Generate coverage report'
  task :report do
    if File.exist?('coverage/.resultset.json')
      require 'json'
      data = JSON.parse(File.read('coverage/.resultset.json'))

      if data['RSpec']
        coverage = data['RSpec']['coverage']
        total_lines = 0
        covered_lines = 0

        coverage.each_value do |lines|
          lines.each do |line|
            total_lines += 1
            covered_lines += 1 if line&.positive?
          end
        end

        percentage = total_lines.positive? ? (covered_lines.to_f / total_lines * 100).round(2) : 0
        puts "Coverage: #{percentage}% (#{covered_lines}/#{total_lines} lines)"
      end
    else
      puts 'No coverage data found'
    end
  end
end
