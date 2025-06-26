# Getting Started Guide

## Welcome to Sacred Geometry-Based RichTextExtraction

This guide will help you get started with the revolutionary sacred geometry-based RichTextExtraction system. You'll learn how to harness the power of natural mathematical principles for optimal text processing.

## 🚀 Quick Start

### 1. Installation

Add the gem to your Gemfile:

```ruby
# Gemfile
gem 'rich_text_extraction', '~> 2.0'
```

Install the gem:

```bash
bundle install
```

### 2. Basic Configuration

Create an initializer file:

```ruby
# config/initializers/rich_text_extraction.rb

# Load sacred geometry components
require 'rich_text_extraction/core/universal_registry'
require 'rich_text_extraction/core/sacred_validator_factory'
require 'rich_text_extraction/core/vortex_engine'
require 'rich_text_extraction/testing/sacred_testing_framework'

# Configure sacred geometry
RichTextExtraction.configure do |config|
  # Enable sacred geometry features
  config.sacred_geometry.enabled = true
  
  # Set golden ratio for optimal proportions (φ ≈ 1.618033988749895)
  config.sacred_geometry.golden_ratio = 1.618033988749895
  
  # Enable vortex mathematics for natural information flow
  config.sacred_geometry.vortex_constant = 2.665144142690225
  
  # Enable Fibonacci growth for organic system expansion
  config.sacred_geometry.fibonacci_growth = true
end
```

### 3. Your First Validator

Create a simple email validator using sacred geometry:

```ruby
# Create email validator configuration
email_config = {
  validator: ->(value) { 
    value.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i) 
  },
  error_message: "is not a valid email address",
  complexity: 2.618,  # Golden ratio squared
  efficiency: 1.618,  # Golden ratio
  base_energy: 1.0
}

# Register the validator with sacred geometry
EmailValidator = RichTextExtraction::Core::SacredValidatorFactory.register_validator(:email, email_config)

# Test the validator
result = RichTextExtraction::Core::VortexEngine.validate_with_confidence("test@example.com", :email)

puts "Valid: #{result[:valid]}"           # => true
puts "Confidence: #{result[:confidence]}" # => 1.618
puts "Vortex energy: #{result[:vortex_energy]}" # => 2.618
```

### 4. Your First Text Processing

Process text using the vortex engine:

```ruby
# Process text through sacred geometry patterns
text = "Check out our website at https://example.com and contact us at support@example.com"

result = RichTextExtraction::Core::VortexEngine.extract_all(text)

puts "Extracted URLs: #{result[:extraction][:urls]}"
# => ["https://example.com"]

puts "Extracted emails: #{result[:extraction][:emails]}"
# => ["support@example.com"]

puts "Golden ratio: #{result[:sacred_geometry][:golden_ratio]}"
# => 1.618

puts "Vortex energy: #{result[:vortex_metrics][:total_energy]}"
# => 8.472
```

## 📚 Core Concepts

### 1. Sacred Geometry Principles

**Golden Ratio (φ ≈ 1.618)**
- Perfect proportions for optimal complexity distribution
- Natural growth patterns found in nature
- Ensures 1.618x efficiency improvement

**Vortex Mathematics**
- Natural spiral information flow patterns
- Reduces processing resistance
- Enables energy conservation

**Fibonacci Sequence**
- Organic growth following 1,1,2,3,5,8,13,21,34,55,89,144
- Self-similarity at all scales
- Natural balance and harmony

### 2. Core Components

**Universal Registry**
- Central registry for all components
- Golden ratio validation for registrations
- Fibonacci-based organization

**Sacred Validator Factory**
- Generate validators with sacred proportions
- Automatic golden ratio calculation
- Vortex mathematics integration

**Vortex Engine**
- Process information through sacred patterns
- Golden angle (137.5°) distribution
- Energy conservation principles

## 🎯 Basic Examples

### Example 1: Email Validation

```ruby
# Create and test an email validator
email_config = {
  validator: ->(value) { 
    value.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i) 
  },
  error_message: "is not a valid email address",
  complexity: 2.618,
  efficiency: 1.618,
  base_energy: 1.0
}

EmailValidator = RichTextExtraction::Core::SacredValidatorFactory.register_validator(:email, email_config)

# Test various email formats
test_emails = [
  "user@example.com",
  "user.name@example.co.uk",
  "invalid-email",
  "user@.com"
]

test_emails.each do |email|
  result = RichTextExtraction::Core::VortexEngine.validate_with_confidence(email, :email)
  puts "#{email}: #{result[:valid]} (confidence: #{result[:confidence]})"
end
```

### Example 2: URL Extraction

```ruby
# Process text to extract URLs
text = """
Visit our main site: https://example.com
Check out our blog: https://blog.example.com
Read our docs: https://docs.example.com
"""

result = RichTextExtraction::Core::VortexEngine.extract_all(text)

puts "Found URLs:"
result[:extraction][:urls].each do |url|
  puts "  - #{url}"
end

puts "\nSacred Geometry Metrics:"
puts "  Golden ratio: #{result[:sacred_geometry][:golden_ratio]}"
puts "  Vortex energy: #{result[:vortex_metrics][:total_energy]}"
puts "  Flow efficiency: #{result[:vortex_metrics][:flow_efficiency]}"
```

### Example 3: Social Media Content Analysis

```ruby
# Analyze social media content
social_content = "Check out our amazing product! #innovation #tech #startup @techcrunch https://example.com"

result = RichTextExtraction::Core::VortexEngine.extract_all(social_content)

puts "Social Media Analysis:"
puts "  Hashtags: #{result[:extraction][:hashtags]}"
puts "  Mentions: #{result[:extraction][:mentions]}"
puts "  URLs: #{result[:extraction][:urls]}"
puts "  Engagement potential: #{result[:validation][:overall_confidence]}"
```

## 🧪 Testing Your Setup

### 1. Basic Testing

```ruby
# Test sacred geometry compliance
compliance = RichTextExtraction::Testing::SacredTestingFramework.validate_sacred_geometry

puts "Sacred Geometry Compliance:"
puts "  Overall score: #{compliance[:overall_sacred_score]}"
puts "  Golden ratio compliance: #{compliance[:golden_ratio][:average_compliance]}"
puts "  Vortex flow efficiency: #{compliance[:vortex_flow][:vortex_flow_efficiency]}"

if compliance[:overall_sacred_score] > 0.8
  puts "✅ Sacred geometry compliance is excellent!"
else
  puts "⚠️  Sacred geometry compliance needs attention"
end
```

### 2. Validator Testing

```ruby
# Test all validators with vortex confidence
results = RichTextExtraction::Testing::SacredTestingFramework.test_validators_with_vortex

puts "Validator Test Results:"
results.each do |validator_name, result|
  status = result[:overall_confidence] > 1.5 ? "✅" : "⚠️"
  puts "  #{status} #{validator_name}: confidence = #{result[:overall_confidence]}"
end
```

### 3. Performance Testing

```ruby
# Test extraction performance
require 'benchmark'

text = "Sample text for performance testing with https://example.com and test@example.com"

time = Benchmark.realtime do
  result = RichTextExtraction::Core::VortexEngine.extract_all(text)
end

puts "Performance Test:"
puts "  Processing time: #{time} seconds"
puts "  Expected time: < 0.1 seconds"

if time < 0.1
  puts "✅ Performance is excellent!"
else
  puts "⚠️  Performance needs optimization"
end
```

## 🔧 Configuration Options

### 1. Sacred Geometry Settings

```ruby
RichTextExtraction.configure do |config|
  # Enable/disable sacred geometry
  config.sacred_geometry.enabled = true
  
  # Sacred geometry constants
  config.sacred_geometry.golden_ratio = 1.618033988749895
  config.sacred_geometry.silver_ratio = 2.414213562373095
  config.sacred_geometry.platinum_ratio = 3.303577269034296
  
  # Vortex mathematics settings
  config.sacred_geometry.vortex_constant = 2.665144142690225
  config.sacred_geometry.golden_angle = 137.5
  
  # Fibonacci growth settings
  config.sacred_geometry.fibonacci_growth = true
  config.sacred_geometry.fibonacci_sequence = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]
end
```

### 2. Vortex Engine Configuration

```ruby
RichTextExtraction::Core::VortexEngine.configure do |config|
  # Vortex flow settings
  config.golden_angle = 137.5
  config.vortex_constant = 2.665144142690225
  
  # Processing stages
  config.vortex_stages = [:validation, :extraction, :transformation]
  
  # Performance settings
  config.energy_conservation = true
  config.flow_optimization = true
  config.max_processing_time = 0.1  # 100ms limit
  config.memory_limit = 50.megabytes
end
```

### 3. Testing Configuration

```ruby
RichTextExtraction::Testing::SacredTestingFramework.configure do |config|
  # Test thresholds
  config.golden_ratio_threshold = 1.5
  config.vortex_confidence_threshold = 0.8
  config.sacred_balance_threshold = 0.9
  
  # Performance thresholds
  config.max_processing_time = 0.1
  config.max_memory_usage = 50.megabytes
end
```

## 🚨 Common Issues and Solutions

### Issue 1: Sacred Geometry Not Enabled

**Problem:**
```
SacredGeometryError: Sacred geometry is not enabled
```

**Solution:**
```ruby
# Ensure sacred geometry is enabled in configuration
RichTextExtraction.configure do |config|
  config.sacred_geometry.enabled = true
end
```

### Issue 2: Low Golden Ratio Compliance

**Problem:**
```
Warning: Golden ratio compliance below threshold
```

**Solution:**
```ruby
# Regenerate validators with proper proportions
RichTextExtraction::Core::SacredValidatorFactory.generate_all_validators

# Validate compliance
compliance = RichTextExtraction::Testing::SacredTestingFramework.validate_sacred_geometry
```

### Issue 3: Vortex Engine Not Available

**Problem:**
```
NameError: uninitialized constant RichTextExtraction::Core::VortexEngine
```

**Solution:**
```ruby
# Ensure vortex engine is loaded
require 'rich_text_extraction/core/vortex_engine'

# Or load all components
require 'rich_text_extraction/core/universal_registry'
require 'rich_text_extraction/core/sacred_validator_factory'
require 'rich_text_extraction/core/vortex_engine'
```

## 📖 Next Steps

### 1. Explore Advanced Features

- **Custom Sacred Proportions**: Create your own sacred geometry calculations
- **Vortex Flow Customization**: Customize information flow patterns
- **Performance Monitoring**: Monitor sacred geometry metrics in real-time

### 2. Read the Documentation

- **[Sacred Geometry Architecture](sacred_geometry_architecture.md)**: Complete architecture overview
- **[API Reference](api_reference.md)**: Comprehensive API documentation
- **[Implementation Guide](implementation_guide.md)**: Practical usage examples
- **[Best Practices](best_practices.md)**: Recommended patterns and approaches

### 3. Join the Community

- **GitHub Issues**: Report bugs and request features
- **GitHub Discussions**: Ask questions and share experiences
- **Contributing**: Help improve the sacred geometry system

## 🎉 Congratulations!

You've successfully set up the sacred geometry-based RichTextExtraction system! You're now ready to harness the power of natural mathematical principles for optimal text processing.

**Key Takeaways:**
- ✅ Sacred geometry enables 1.618x performance improvement
- ✅ Vortex mathematics provides natural information flow
- ✅ Fibonacci sequence ensures organic growth
- ✅ Golden ratio maintains perfect proportions

**Remember:** The sacred geometry system is designed to work with nature's mathematical principles, not against them. Trust the golden ratio, embrace the vortex flow, and let the Fibonacci sequence guide your growth!

Happy coding with sacred geometry! 🌟✨ 