# Migration Guide

## Overview

This guide helps you migrate from the traditional RichTextExtraction architecture to the new sacred geometry-based system. The migration preserves existing functionality while adding the power of natural mathematical principles.

## Pre-Migration Checklist

### 1. System Requirements

Ensure your system supports the sacred geometry components:

```ruby
# Check Ruby version (2.7+ recommended)
ruby_version = RUBY_VERSION
puts "Ruby version: #{ruby_version}"

# Check for required gems
required_gems = ['rspec', 'activesupport', 'json']
required_gems.each do |gem|
  begin
    require gem
    puts "✓ #{gem} available"
  rescue LoadError
    puts "✗ #{gem} missing - please install"
  end
end
```

### 2. Backup Current System

Before migration, backup your current configuration:

```ruby
# Backup current validators
current_validators = RichTextExtraction::Validators.constants.map(&:to_s)
File.write('backup/current_validators.json', current_validators.to_json)

# Backup current configuration
current_config = RichTextExtraction.configuration
File.write('backup/current_config.json', current_config.to_json)
```

## Step-by-Step Migration

### Step 1: Update Dependencies

Update your Gemfile to include sacred geometry components:

```ruby
# Gemfile
gem 'rich_text_extraction', '~> 2.0'  # New version with sacred geometry

# Optional: Add performance monitoring
gem 'benchmark-ips'  # For performance testing
gem 'memory_profiler'  # For memory analysis
```

### Step 2: Load Sacred Geometry Components

Update your application initialization:

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
  
  # Set golden ratio for optimal proportions
  config.sacred_geometry.golden_ratio = 1.618033988749895
  
  # Enable vortex mathematics
  config.sacred_geometry.vortex_constant = 2.665144142690225
  
  # Enable Fibonacci growth
  config.sacred_geometry.fibonacci_growth = true
  
  # Maintain backward compatibility
  config.backward_compatibility.enabled = true
end
```

### Step 3: Migrate Validators

#### Before (Traditional Approach)

```ruby
# Old validator class
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless valid_email?(value)
      record.errors.add(attribute, "is not a valid email")
    end
  end
  
  private
  
  def valid_email?(value)
    value.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end
end
```

#### After (Sacred Geometry Approach)

```ruby
# New sacred geometry validator
email_config = {
  validator: ->(value) { 
    value.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i) 
  },
  error_message: "is not a valid email",
  complexity: 2.618,  # Golden ratio squared
  efficiency: 1.618,  # Golden ratio
  base_energy: 1.0
}

# Register with sacred geometry
EmailValidator = RichTextExtraction::Core::SacredValidatorFactory.register_validator(:email, email_config)
```

### Step 4: Migrate Text Processing

#### Before (Traditional Approach)

```ruby
# Old text processing
class TextProcessor
  def self.extract_links(text)
    text.scan(/https?:\/\/[^\s]+/)
  end
  
  def self.extract_emails(text)
    text.scan(/[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+/i)
  end
end

# Usage
links = TextProcessor.extract_links("Check out https://example.com")
emails = TextProcessor.extract_emails("Contact test@example.com")
```

#### After (Vortex Engine Approach)

```ruby
# New vortex engine processing
text = "Check out https://example.com and contact test@example.com"

# Process through vortex engine
result = RichTextExtraction::Core::VortexEngine.extract_all(text)

# Access results with sacred geometry metadata
links = result[:extraction][:links]
emails = result[:extraction][:emails]

# Access sacred geometry metrics
golden_ratio = result[:sacred_geometry][:golden_ratio]
vortex_energy = result[:vortex_metrics][:total_energy]
```

### Step 5: Migrate Testing

#### Before (Traditional RSpec)

```ruby
# Old RSpec tests
RSpec.describe EmailValidator do
  it "validates email format" do
    validator = EmailValidator.new
    expect(validator.validate("test@example.com")).to be true
    expect(validator.validate("invalid-email")).to be false
  end
end
```

#### After (Sacred Testing Framework)

```ruby
# New sacred geometry tests
RSpec.describe "Sacred Geometry Validators" do
  it "tests validators with vortex confidence" do
    results = RichTextExtraction::Testing::SacredTestingFramework.test_validators_with_vortex
    
    expect(results[:email][:overall_confidence]).to be > 1.5
    expect(results[:email][:vortex_energy]).to be > 2.0
  end
  
  it "validates sacred geometry compliance" do
    compliance = RichTextExtraction::Testing::SacredTestingFramework.validate_sacred_geometry
    
    expect(compliance[:overall_sacred_score]).to be > 0.8
    expect(compliance[:golden_ratio][:average_compliance]).to be > 0.9
  end
end
```

## Advanced Migration Scenarios

### 1. Custom Validator Migration

#### Before

```ruby
# Custom phone validator
class PhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless valid_phone?(value)
      record.errors.add(attribute, "is not a valid phone number")
    end
  end
  
  private
  
  def valid_phone?(value)
    # Complex phone validation logic
    cleaned = value.gsub(/[\s\-\(\)]/, '')
    cleaned.match?(/^\+?1?\d{10,15}$/)
  end
end
```

#### After

```ruby
# Sacred geometry phone validator
phone_config = {
  validator: ->(value) {
    cleaned = value.gsub(/[\s\-\(\)]/, '')
    cleaned.match?(/^\+?1?\d{10,15}$/)
  },
  error_message: "is not a valid phone number",
  complexity: 3.236,  # Golden ratio + 1
  efficiency: 2.0,    # Optimized for phone validation
  base_energy: 1.618, # Golden ratio
  preprocessing: ->(value) { value.gsub(/[\s\-\(\)]/, '') },
  validation_steps: 2
}

PhoneValidator = RichTextExtraction::Core::SacredValidatorFactory.register_validator(:phone, phone_config)
```

### 2. Complex Text Processing Migration

#### Before

```ruby
# Complex text processor
class AdvancedTextProcessor
  def self.process_text(text)
    {
      links: extract_links(text),
      emails: extract_emails(text),
      phones: extract_phones(text),
      hashtags: extract_hashtags(text),
      mentions: extract_mentions(text)
    }
  end
  
  private
  
  def self.extract_links(text)
    text.scan(/https?:\/\/[^\s]+/)
  end
  
  def self.extract_emails(text)
    text.scan(/[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+/i)
  end
  
  # ... other extraction methods
end
```

#### After

```ruby
# Vortex engine processing with sacred geometry
def process_text_with_vortex(text)
  result = RichTextExtraction::Core::VortexEngine.extract_all(text)
  
  {
    links: result[:extraction][:links],
    emails: result[:extraction][:emails],
    phones: result[:extraction][:phones],
    hashtags: result[:extraction][:hashtags],
    mentions: result[:extraction][:mentions],
    sacred_geometry: result[:sacred_geometry],
    vortex_metrics: result[:vortex_metrics],
    confidence_scores: result[:validation][:confidence_scores]
  }
end
```

### 3. Rails Model Migration

#### Before

```ruby
# Rails model with traditional validators
class User < ApplicationRecord
  validates :email, presence: true, email: true
  validates :website, url: true, allow_blank: true
  validates :phone, phone: true, allow_blank: true
  
  def extract_content_info
    AdvancedTextProcessor.process_text(bio)
  end
end
```

#### After

```ruby
# Rails model with sacred geometry
class User < ApplicationRecord
  validates :email, presence: true, email: true
  validates :website, url: true, allow_blank: true
  validates :phone, phone: true, allow_blank: true
  
  def extract_content_info_with_vortex
    return {} if bio.blank?
    
    result = RichTextExtraction::Core::VortexEngine.extract_all(bio)
    
    {
      extracted_data: result[:extraction],
      confidence_scores: result[:validation][:confidence_scores],
      sacred_metrics: result[:sacred_geometry],
      processing_metadata: {
        golden_ratio: result[:sacred_geometry][:golden_ratio],
        vortex_energy: result[:vortex_metrics][:total_energy],
        processed_at: Time.current
      }
    }
  end
  
  # Backward compatibility method
  def extract_content_info
    extract_content_info_with_vortex[:extracted_data]
  end
end
```

## Testing Migration

### 1. Update Test Configuration

```ruby
# spec/rails_helper.rb or spec_helper.rb

# Load sacred testing framework
require 'rich_text_extraction/testing/sacred_testing_framework'

RSpec.configure do |config|
  # Include sacred geometry helpers
  config.include RichTextExtraction::Testing::SacredTestingFramework::Helpers
  
  # Configure sacred geometry testing
  config.before(:suite) do
    RichTextExtraction::Testing::SacredTestingFramework.configure do |config|
      config.golden_ratio_threshold = 1.5
      config.vortex_confidence_threshold = 0.8
      config.sacred_balance_threshold = 0.9
    end
  end
end
```

### 2. Migrate Existing Tests

#### Before

```ruby
# Old test structure
RSpec.describe User do
  it "validates email format" do
    user = User.new(email: "invalid-email")
    user.valid?
    expect(user.errors[:email]).to include("is not a valid email")
  end
  
  it "extracts content information" do
    user = User.new(bio: "Check https://example.com and contact test@example.com")
    result = user.extract_content_info
    expect(result[:links]).to include("https://example.com")
    expect(result[:emails]).to include("test@example.com")
  end
end
```

#### After

```ruby
# New sacred geometry test structure
RSpec.describe User do
  it "validates with vortex confidence" do
    user = User.new(email: "test@example.com")
    
    # Test with sacred geometry validation
    validation_result = RichTextExtraction::Core::VortexEngine.validate_with_confidence(
      user.email, 
      :email
    )
    
    expect(validation_result[:valid]).to be true
    expect(validation_result[:confidence]).to be > 1.5
  end
  
  it "extracts content with sacred geometry" do
    user = User.new(bio: "Check https://example.com and contact test@example.com")
    result = user.extract_content_info_with_vortex
    
    expect(result[:extracted_data][:links]).to include("https://example.com")
    expect(result[:extracted_data][:emails]).to include("test@example.com")
    expect(result[:sacred_metrics][:golden_ratio]).to be > 1.5
    expect(result[:confidence_scores][:overall]).to be > 0.8
  end
  
  it "maintains sacred geometry compliance" do
    compliance = RichTextExtraction::Testing::SacredTestingFramework.validate_sacred_geometry
    expect(compliance[:overall_sacred_score]).to be > 0.8
  end
end
```

## Performance Monitoring

### 1. Set Up Performance Monitoring

```ruby
# config/initializers/performance_monitoring.rb

# Monitor sacred geometry performance
ActiveSupport::Notifications.subscribe "rich_text_extraction.vortex_processing" do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  
  Rails.logger.info "Vortex processing completed:"
  Rails.logger.info "  Duration: #{event.duration}ms"
  Rails.logger.info "  Golden ratio: #{event.payload[:golden_ratio]}"
  Rails.logger.info "  Vortex energy: #{event.payload[:vortex_energy]}"
end
```

### 2. Performance Comparison

```ruby
# Performance comparison script
require 'benchmark'

# Compare old vs new performance
text = "Check out https://example.com and contact test@example.com"

# Old method
old_time = Benchmark.realtime do
  1000.times { TextProcessor.extract_links(text) }
end

# New method
new_time = Benchmark.realtime do
  1000.times { RichTextExtraction::Core::VortexEngine.extract_all(text) }
end

puts "Old method: #{old_time} seconds"
puts "New method: #{new_time} seconds"
puts "Performance improvement: #{(old_time / new_time).round(2)}x"
```

## Rollback Plan

### 1. Backup Sacred Geometry Configuration

```ruby
# Backup sacred geometry configuration
sacred_config = {
  golden_ratio: RichTextExtraction.configuration.sacred_geometry.golden_ratio,
  vortex_constant: RichTextExtraction.configuration.sacred_geometry.vortex_constant,
  fibonacci_growth: RichTextExtraction.configuration.sacred_geometry.fibonacci_growth
}

File.write('backup/sacred_geometry_config.json', sacred_config.to_json)
```

### 2. Rollback Script

```ruby
# Rollback script
def rollback_to_traditional
  # Disable sacred geometry
  RichTextExtraction.configure do |config|
    config.sacred_geometry.enabled = false
    config.backward_compatibility.enabled = true
  end
  
  # Restore traditional validators
  load 'backup/traditional_validators.rb'
  
  puts "Rollback completed. Sacred geometry disabled."
end
```

## Post-Migration Validation

### 1. Functionality Validation

```ruby
# Validate all functionality works
def validate_migration
  # Test validators
  validators_working = test_all_validators
  
  # Test text processing
  processing_working = test_text_processing
  
  # Test sacred geometry compliance
  sacred_compliance = RichTextExtraction::Testing::SacredTestingFramework.validate_sacred_geometry
  
  {
    validators: validators_working,
    processing: processing_working,
    sacred_compliance: sacred_compliance[:overall_sacred_score] > 0.8
  }
end
```

### 2. Performance Validation

```ruby
# Validate performance improvements
def validate_performance
  results = RichTextExtraction::Testing::SacredTestingFramework.test_extraction_with_golden_ratio
  
  {
    golden_ratio_efficiency: results[:golden_ratio_efficiency] > 1.5,
    vortex_flow_metrics: results[:vortex_flow_metrics][:average_flow] > 0.9,
    overall_performance: results[:overall_performance] > 1.0
  }
end
```

This migration guide provides a comprehensive path for transitioning to the sacred geometry-based RichTextExtraction system while maintaining backward compatibility and ensuring optimal performance. 