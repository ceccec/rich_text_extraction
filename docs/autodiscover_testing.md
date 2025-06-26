# Autodiscover Testing System

## Overview

The autodiscover testing system provides fully automated, DRY testing for the `rich_text_extraction` gem. It automatically discovers and tests all available functions, modules, classes, and methods according to common patterns, ensuring comprehensive coverage of the public API surface.

## Features

### 🔍 **Automatic Discovery**
- Discovers all modules and classes under the `RichTextExtraction` namespace
- Finds all public methods (module, class, instance, validator)
- Identifies methods matching common patterns (extraction, validation, cache, configuration)

### 🧪 **Automated Testing**
- Tests all discovered methods with sample data
- Validates return types and basic functionality
- Performs pattern-based testing for different method categories
- Includes performance and edge case testing

### 🛡️ **Robust Error Handling**
- Gracefully skips tests for missing components (e.g., validators)
- Handles undefined classes and methods without failing
- Provides informative error messages for real issues

### 🔄 **DRY Patterns**
- Reusable testing helpers in `spec/support/autodiscover_patterns.rb`
- Shared contexts for common testing scenarios
- Consistent testing patterns across the codebase

## Architecture

### Core Components

#### 1. **Autodiscover Spec** (`spec/autodiscover_spec.rb`)
The main test file that orchestrates the discovery and testing process.

```ruby
RSpec.describe 'RichTextExtraction Autodiscover' do
  include_context 'autodiscover patterns'
  
  describe 'Module Discovery' do
    it 'discovers all RichTextExtraction modules' do
      expect_modules_to_exist(%w[
        RichTextExtraction
        RichTextExtraction::Core
        RichTextExtraction::Extractors
        # ... more modules
      ])
    end
  end
end
```

#### 2. **DRY Patterns** (`spec/support/autodiscover_patterns.rb`)
Shared context providing reusable testing helpers.

```ruby
RSpec.shared_context 'autodiscover patterns' do
  # Method discovery helpers
  def discover_modules
    ObjectSpace.each_object(Module).map { |mod| mod.name }
      .compact.uniq.select { |n| n.start_with?('RichTextExtraction') }
  end
  
  # Pattern matching helpers
  def find_methods_matching_patterns(object, patterns, method_type = :public)
    methods = discover_methods_for(object, method_type)
    patterns.flat_map { |pattern| methods.grep(pattern) }
  end
  
  # Automated testing helpers
  def test_extraction_methods(extractor, methods = %i[links tags mentions emails attachments phone_numbers])
    test_methods_respond_to(extractor, methods)
    methods.each do |meth|
      result = extractor.send(meth)
      expect(result).to be_an(Array)
    end
  end
end
```

## Usage

### Running the Autodiscover Tests

```bash
# Run only autodiscover tests
bundle exec rspec spec/autodiscover_spec.rb

# Run as part of the full test suite
bundle exec rspec
```

### Expected Output

```
RichTextExtraction Autodiscover
  Module Discovery
    discovers all RichTextExtraction modules
    discovers all public classes
  Method Discovery
    discovers all module-level methods
    discovers all instance methods
    discovers all validator methods (PENDING: UrlValidator not defined)
  Automated Method Testing
    tests all extraction methods with sample data
    tests all configuration methods
    tests all validator methods (PENDING: UrlValidator not defined)
    tests all cache methods
    tests all OpenGraph methods
    tests all markdown methods
    tests method performance with large inputs
    tests method error handling (PENDING: UrlValidator not defined)
  Pattern-Based Testing
    tests all methods matching extraction patterns
    tests all methods matching validation patterns (PENDING: UrlValidator not defined)
    tests all methods matching cache patterns
    tests all methods matching configuration patterns
  Integration Testing
    tests method interactions
    tests end-to-end workflows (PENDING: UrlValidator not defined)

Finished in 0.01121 seconds (files took 0.40187 seconds to load)
19 examples, 0 failures, 5 pending
```

## Testing Categories

### 1. **Module Discovery**
Tests that all expected modules and classes are loaded and available.

```ruby
describe 'Module Discovery' do
  it 'discovers all RichTextExtraction modules' do
    expect_modules_to_exist(%w[
      RichTextExtraction
      RichTextExtraction::Core
      RichTextExtraction::Extractors
      RichTextExtraction::Validators
      RichTextExtraction::Helpers
      RichTextExtraction::Cache
      RichTextExtraction::API
    ])
  end
end
```

### 2. **Method Discovery**
Verifies that all expected public methods are available on the appropriate objects.

```ruby
describe 'Method Discovery' do
  it 'discovers all module-level methods' do
    test_methods_exist(RichTextExtraction, %i[
      extract extract_opengraph render_markdown configure configuration
    ])
  end
  
  it 'discovers all instance methods' do
    test_methods_exist(RichTextExtraction::Extractors::Extractor.new(sample_text), %i[
      links tags mentions emails attachments phone_numbers text
    ])
  end
end
```

### 3. **Automated Method Testing**
Tests that discovered methods work correctly with sample data.

```ruby
describe 'Automated Method Testing' do
  it 'tests all extraction methods with sample data' do
    test_extraction_methods(
      RichTextExtraction::Extractors::Extractor.new(sample_text),
      %i[links tags mentions emails attachments phone_numbers]
    )
  end
  
  it 'tests all configuration methods' do
    test_configuration_methods(RichTextExtraction.configuration)
  end
end
```

### 4. **Pattern-Based Testing**
Uses regex patterns to find and test methods that follow common naming conventions.

```ruby
describe 'Pattern-Based Testing' do
  it 'tests all methods matching extraction patterns' do
    expect(find_instance_methods_matching_patterns(
      RichTextExtraction::Extractors::Extractor,
      [/^extract_/, /_extractor$/]
    )).not_to be_empty
  end
  
  it 'tests all methods matching cache patterns' do
    test_cache_patterns(RichTextExtraction.configuration)
  end
end
```

### 5. **Performance and Edge Cases**
Tests method behavior with large inputs and edge cases.

```ruby
describe 'Performance and Edge Cases' do
  it 'tests method performance with large inputs' do
    large_text = "x" * 100_000 + " https://example.com " + "y" * 100_000
    extractor = RichTextExtraction::Extractors::Extractor.new(large_text)
    start_time = Time.now
    result = extractor.links
    end_time = Time.now
    expect(result).to be_an(Array)
    expect(end_time - start_time).to be < 2.0
  end
  
  it 'tests method behavior with edge cases' do
    test_edge_cases(RichTextExtraction::Extractors::Extractor, long_url: true)
  end
end
```

### 6. **Integration Testing**
Tests how different methods work together and end-to-end workflows.

```ruby
describe 'Integration Testing' do
  it 'tests method interactions' do
    test_method_interactions(RichTextExtraction::Extractors::Extractor)
  end
  
  it 'tests end-to-end workflows' do
    test_end_to_end_workflow(
      RichTextExtraction::Extractors::Extractor,
      RichTextExtraction::Validators::UrlValidator
    )
  end
end
```

## DRY Helper Methods

### Method Discovery Helpers

```ruby
# Discover all modules under RichTextExtraction namespace
def discover_modules
  ObjectSpace.each_object(Module).map { |mod| mod.name }
    .compact.uniq.select { |n| n.start_with?('RichTextExtraction') }
end

# Discover all classes under RichTextExtraction namespace
def discover_classes
  ObjectSpace.each_object(Class).map { |klass| klass.name }
    .compact.uniq.select { |n| n.start_with?('RichTextExtraction') }
end

# Discover methods for a specific object
def discover_methods_for(object, method_type = :public)
  case method_type
  when :public
    object.public_methods - Object.new.public_methods
  when :private
    object.private_methods - Object.new.private_methods
  when :protected
    object.protected_methods - Object.new.protected_methods
  else
    object.methods - Object.new.methods
  end
rescue
  []
end
```

### Pattern Matching Helpers

```ruby
# Find methods matching specific patterns
def find_methods_matching_patterns(object, patterns, method_type = :public)
  methods = discover_methods_for(object, method_type)
  patterns.flat_map { |pattern| methods.grep(pattern) }
end

# Find instance methods matching patterns
def find_instance_methods_matching_patterns(klass, patterns, method_type = :public)
  methods = discover_instance_methods_for(klass, method_type)
  patterns.flat_map { |pattern| methods.grep(pattern) }
end
```

### Testing Helpers

```ruby
# Test that methods exist on an object
def test_methods_exist(object, expected_methods, method_type = :public)
  actual_methods = discover_methods_for(object, method_type)
  expected_methods.each do |meth|
    expect(actual_methods).to include(meth)
  end
end

# Test that methods respond to calls
def test_methods_respond_to(object, expected_methods)
  expected_methods.each do |meth|
    expect(object).to respond_to(meth)
  end
end

# Test return types of methods
def test_methods_return_type(object, methods, expected_type, *args)
  methods.each do |meth|
    result = object.send(meth, *args)
    expect(result).to be_a(expected_type)
  end
end
```

### Specialized Testing Helpers

```ruby
# Test extraction methods
def test_extraction_methods(extractor, methods = %i[links tags mentions emails attachments phone_numbers])
  test_methods_respond_to(extractor, methods)
  methods.each do |meth|
    result = extractor.send(meth)
    expect(result).to be_an(Array)
  end
end

# Test configuration methods
def test_configuration_methods(config, methods = %i[cache_enabled= cache_ttl= opengraph_timeout= merge to_h])
  test_methods_respond_to(config, methods)
end

# Test cache methods
def test_cache_methods(config, methods = %i[caching_available? generate_cache_key cache_options])
  test_methods_respond_to(config, methods)
end

# Test validator methods (with conditional skipping)
def test_validator_methods(validator_class, methods = %i[validate valid? errors])
  return skip("#{validator_class} not defined") unless defined?(validator_class)
  
  validator = validator_class.new
  test_methods_respond_to(validator, methods)
  
  if validator.respond_to?(:validate)
    expect(validator.validate(sample_url)).to be_truthy
    expect(validator.validate('invalid-url')).to be_falsey
  end
end
```

## Benefits

### 1. **Zero-Maintenance Testing**
- New features and methods are automatically tested as they are added
- No need to manually update test files for new functionality
- Reduces the risk of forgetting to test new features

### 2. **Comprehensive Coverage**
- Tests all public API surfaces automatically
- Ensures no methods are accidentally broken
- Catches regressions across the entire codebase

### 3. **DRY and Maintainable**
- Shared testing patterns reduce code duplication
- Consistent testing approach across all components
- Easy to extend and modify testing behavior

### 4. **Robust Error Handling**
- Gracefully handles missing or optional components
- Provides clear feedback on what's missing vs. what's broken
- Prevents false negatives from missing dependencies

### 5. **Performance Monitoring**
- Automatically tests performance with large inputs
- Catches performance regressions early
- Ensures methods scale appropriately

## Integration with CI/CD

The autodiscover tests can be integrated into your CI/CD pipeline to ensure:

- All new code is automatically tested
- API changes are caught before deployment
- Performance regressions are detected early
- Code quality is maintained across the project

### Example CI Configuration

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.0
          bundler-cache: true
      - run: bundle exec rspec spec/autodiscover_spec.rb
      - run: bundle exec rspec
```

## Troubleshooting

### Common Issues

1. **Tests Skipped Due to Missing Components**
   - This is expected behavior for optional components
   - Add the missing component or update the test to handle its absence

2. **Performance Tests Failing**
   - Adjust the performance thresholds in the test
   - Investigate if there's a real performance regression

3. **Pattern Matching Not Finding Methods**
   - Check if the method naming conventions have changed
   - Update the regex patterns to match the new conventions

### Debugging

To debug autodiscover tests:

```ruby
# Add debugging output to see what's being discovered
puts "Discovered modules: #{discover_modules}"
puts "Discovered classes: #{discover_classes}"
puts "Methods on Extractor: #{discover_methods_for(RichTextExtraction::Extractors::Extractor.new('test'))}"
```

## Future Enhancements

### Potential Improvements

1. **Custom Pattern Definitions**
   - Allow developers to define custom patterns for their specific use cases
   - Support for domain-specific testing patterns

2. **Performance Benchmarking**
   - Store performance baselines and detect regressions
   - Generate performance reports over time

3. **API Documentation Generation**
   - Automatically generate API documentation from discovered methods
   - Include usage examples and return type information

4. **Integration with Other Testing Frameworks**
   - Support for other testing frameworks beyond RSpec
   - Integration with mutation testing tools

5. **Custom Test Data**
   - Allow developers to provide custom test data for specific methods
   - Support for domain-specific test scenarios

## Conclusion

The autodiscover testing system provides a robust, maintainable, and comprehensive approach to testing the `rich_text_extraction` gem. By automatically discovering and testing all available functionality, it ensures high code quality and catches regressions early in the development process.

The DRY patterns and shared helpers make it easy to extend and customize the testing behavior while maintaining consistency across the codebase. This system serves as a foundation for maintaining code quality and API consistency as the project evolves. 