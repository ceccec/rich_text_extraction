# Golden Ratio Architecture for Rich Text Extraction

## Overview

The Rich Text Extraction gem implements a **Golden Ratio Architecture** that combines mathematical harmony with intelligent error handling and caching. This architecture ensures optimal performance, reliability, and maintainability through the application of sacred geometry principles.

## Core Principles

### 1. Golden Ratio (φ = 1.618033988749895)

The golden ratio is used throughout the system for:
- **Exponential backoff timing** in error handling
- **Proportional scaling** of retry attempts
- **Harmonious performance** balancing between speed and reliability

### 2. Intelligent Caching

The system implements a sophisticated caching strategy that:
- **Adapts to error rates** - uses cache when error ratio is low (< 10%)
- **Self-invalidates** on registry changes
- **Optimizes memory usage** with TTL-based expiration
- **Maintains consistency** across distributed operations

### 3. Error Handling with Exponential Backoff

Error handling follows the golden ratio principle:
```ruby
sleep_time = (GOLDEN_RATIO ** attempts) * 0.1
```

This creates a harmonious progression:
- 1st retry: ~0.1 seconds
- 2nd retry: ~0.26 seconds  
- 3rd retry: ~0.42 seconds

## Architecture Components

### RegistryComponent

The `RegistryComponent` class represents individual components with ActiveRecord-style features:

```ruby
class RegistryComponent
  include ActiveModel::Model
  include ActiveModel::Validations
  
  # Golden ratio error handling
  def save!
    Registry.instance.with_error_handling do
      Registry.instance.register_component(self)
    end
  end
  
  # OpenGraph compatibility
  def as_opengraph
    {
      "og:title" => name,
      "og:type" => type,
      "og:description" => description,
      # ... more metadata
    }
  end
end
```

### Registry

The central registry manages all components with intelligent caching:

```ruby
class Registry
  include Singleton
  
  # Golden ratio constants
  GOLDEN_RATIO = 1.618033988749895
  MAX_RETRY_ATTEMPTS = 3
  CACHE_TTL = 300 # 5 minutes
  
  # Error handling with exponential backoff
  def with_error_handling(max_attempts = MAX_RETRY_ATTEMPTS)
    attempts = 0
    begin
      attempts += 1
      yield
    rescue StandardError => e
      @error_count += 1
      if attempts < max_attempts
        sleep_time = (GOLDEN_RATIO ** attempts) * 0.1
        sleep(sleep_time)
        retry
      else
        log_error(e, attempts)
        raise e
      end
    end
  end
end
```

## Caching Strategy

### Adaptive Cache Usage

The system intelligently decides when to use cache based on error rates:

```ruby
def should_use_cache?
  operation_ratio < 0.1 # Use cache if error rate is less than 10%
end
```

### Cache Operations

```ruby
# Store with TTL
registry.cache_set('key', value, ttl = 300)

# Retrieve with expiration check
cached = registry.cache_get('key')

# Clear all cache
registry.cache_clear()
```

### Cache Invalidation

Cache is automatically invalidated when:
- New components are registered
- Existing components are updated
- Components are removed
- Registry state changes

## Error Handling Patterns

### 1. Component Registration

```ruby
# Automatic retry with golden ratio backoff
component = RegistryComponent.new(
  name: 'MyExtractor',
  type: 'extractor',
  class_name: 'MyExtractorClass'
)
component.save! # Handles errors automatically
```

### 2. Batch Operations

```ruby
# Handle partial failures gracefully
components.each do |comp|
  begin
    comp.save!
  rescue StandardError => e
    # Log error, continue with other components
    Rails.logger.warn("Failed to save #{comp.name}: #{e.message}")
  end
end
```

### 3. Performance Monitoring

```ruby
# Monitor system health
stats = registry.performance_stats
puts "Error ratio: #{stats[:error_ratio]}"
puts "Cache efficiency: #{stats[:cache_size]}"
puts "Total operations: #{stats[:total_operations]}"
```

## Performance Optimization

### Large Scale Operations

The system efficiently handles large numbers of components:

```ruby
# Create 1000 components efficiently
1000.times do |i|
  RegistryComponent.create!(
    name: "Component#{i}",
    type: 'extractor',
    class_name: "Class#{i}"
  )
end

# Query with caching
extractors = Registry.extractors # Uses cache for subsequent calls
```

### Memory Management

```ruby
# Monitor cache size
stats = registry.performance_stats
if stats[:cache_size] > 1000
  registry.cache_clear # Prevent memory bloat
end
```

## Real-World Usage Examples

### 1. Component Lifecycle Management

```ruby
# Create component with error handling
component = RegistryComponent.create!(
  name: 'LinkExtractor',
  type: 'extractor',
  class_name: 'RichTextExtraction::LinkExtractor',
  description: 'Extracts links from rich text'
)

# Update with automatic retry
component.update!(description: 'Updated description')

# Deactivate gracefully
component.deactivate!
```

### 2. Query Optimization

```ruby
# First query - populates cache
extractors = Registry.extractors

# Subsequent queries - use cache
extractors_again = Registry.extractors # Fast cached response

# Query by type with caching
validators = Registry.validators
helpers = Registry.helpers
```

### 3. Error Recovery

```ruby
# System automatically recovers from temporary failures
begin
  component.save!
rescue StandardError => e
  # Component will be retried with exponential backoff
  # If all retries fail, error is logged and raised
  Rails.logger.error("Permanent failure: #{e.message}")
end
```

## Configuration

### Golden Ratio Constants

```ruby
# Customize golden ratio behavior
RichTextExtraction::Registry::GOLDEN_RATIO = 1.618033988749895
RichTextExtraction::Registry::MAX_RETRY_ATTEMPTS = 5
RichTextExtraction::Registry::CACHE_TTL = 600 # 10 minutes
```

### Performance Tuning

```ruby
# Adjust cache behavior
def should_use_cache?
  operation_ratio < 0.05 # More conservative caching
end

# Custom error handling
def with_error_handling(max_attempts = MAX_RETRY_ATTEMPTS)
  # Custom implementation
end
```

## Benefits

### 1. Reliability
- **Automatic retry** with intelligent backoff
- **Graceful degradation** under load
- **Error tracking** and monitoring

### 2. Performance
- **Intelligent caching** reduces database queries
- **Adaptive behavior** based on system health
- **Memory efficient** with TTL-based expiration

### 3. Maintainability
- **Consistent patterns** across the codebase
- **Mathematical harmony** in timing and scaling
- **Self-healing** error recovery

### 4. Scalability
- **Horizontal scaling** with shared registry
- **Load distribution** through caching
- **Resource optimization** with adaptive behavior

## Testing

The golden ratio architecture includes comprehensive testing:

```ruby
# Test exponential backoff
it 'retries operations with exponential backoff using golden ratio' do
  # Verify timing follows golden ratio progression
end

# Test cache behavior
it 'uses cache when error ratio is low' do
  # Verify adaptive caching
end

# Test performance
it 'handles many components efficiently' do
  # Verify scalability
end
```

## Conclusion

The Golden Ratio Architecture provides a mathematically harmonious foundation for the Rich Text Extraction gem. By combining sacred geometry principles with intelligent caching and error handling, the system achieves optimal performance, reliability, and maintainability.

The architecture scales from small applications to large distributed systems while maintaining the same elegant patterns and predictable behavior. The golden ratio ensures that all timing and scaling decisions follow natural mathematical principles, creating a system that feels both organic and engineered. 