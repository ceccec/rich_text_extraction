# RegistryComponent Guide

## Overview

`RegistryComponent` is a powerful, ActiveRecord-style component that manages rich text extraction components without requiring a database. It provides full ActiveRecord-like API, OpenGraph compatibility, and in-memory associations.

## Features

### ActiveRecord-Style API
- Validations and callbacks
- Associations (parent/child relationships)
- Scopes and finders
- CRUD operations
- Timestamps and lifecycle methods

### OpenGraph Compatibility
- Automatic OpenGraph attribute formatting
- Metadata integration
- ISO8601 timestamp formatting

### In-Memory Associations
- Parent/child relationships
- Tree structure support
- Cross-referencing capabilities

## Basic Usage

### Creating Components

```ruby
# Basic creation
component = RichTextExtraction::RegistryComponent.new(
  name: "LinkExtractor",
  type: "extractor",
  class_name: "RichTextExtraction::Extractors::LinkExtractor",
  description: "Extracts links from text"
)

# With metadata
component = RichTextExtraction::RegistryComponent.new(
  name: "UrlValidator",
  type: "validator",
  class_name: "RichTextExtraction::Validators::UrlValidator",
  description: "Validates URL format",
  metadata: { category: "validation", priority: 1 }
)
```

### Saving and Validation

```ruby
# Save with validation
component.save! # Raises error if invalid
component.save   # Returns true/false

# Check validation
component.valid?     # => true/false
component.errors     # => ActiveModel::Errors

# Validation errors
component.errors.full_messages
# => ["Name can't be blank", "Type must be one of: extractor, validator, helper, service, job, controller"]
```

### Finding Components

```ruby
# Find by name
component = RichTextExtraction::RegistryComponent.find_by_name("LinkExtractor")

# Find by type
extractors = RichTextExtraction::RegistryComponent.by_type("extractor")

# Scopes
active_components = RichTextExtraction::RegistryComponent.active
inactive_components = RichTextExtraction::RegistryComponent.inactive
```

### Updating Components

```ruby
# Update attributes
component.update!(description: "Updated description")
component.update(active: false) # Returns true/false

# Individual attribute updates
component.description = "New description"
component.save!
```

### Lifecycle Management

```ruby
# Activation/deactivation
component.activate!   # Sets active = true
component.deactivate! # Sets active = false

# Status checks
component.active?   # => true/false
component.inactive? # => true/false

# Persistence checks
component.persisted? # => true if saved to registry
component.new_record? # => true if not yet saved
```

## Associations

### Parent/Child Relationships

```ruby
# Create parent-child relationships
parent = RichTextExtraction::RegistryComponent.new(name: "Parent", type: "extractor", class_name: "ParentClass")
child = RichTextExtraction::RegistryComponent.new(name: "Child", type: "validator", class_name: "ChildClass")

# Add child to parent
parent.add_child(child)
parent.has_children? # => true
child.parent # => parent

# Remove child
parent.remove_child(child)
parent.has_children? # => false
child.parent # => nil

# Tree structure helpers
parent.root?  # => true (no parent)
child.leaf?   # => true (no children)
```

### Cross-Referencing

```ruby
# Build component hierarchies
main_extractor = RichTextExtraction::RegistryComponent.new(
  name: "MainExtractor",
  type: "extractor",
  class_name: "MainExtractorClass"
)

link_validator = RichTextExtraction::RegistryComponent.new(
  name: "LinkValidator",
  type: "validator",
  class_name: "LinkValidatorClass"
)

url_validator = RichTextExtraction::RegistryComponent.new(
  name: "UrlValidator",
  type: "validator",
  class_name: "UrlValidatorClass"
)

# Create hierarchy
main_extractor.add_child(link_validator)
link_validator.add_child(url_validator)

# Navigate relationships
main_extractor.children.first # => link_validator
url_validator.parent.parent # => main_extractor
```

## OpenGraph Integration

### Basic OpenGraph Usage

```ruby
component = RichTextExtraction::RegistryComponent.new(
  name: "LinkExtractor",
  type: "extractor",
  description: "Extracts links from text",
  metadata: { category: "text_processing", priority: 1 }
)

# Get OpenGraph formatted data
og_data = component.as_opengraph
# => {
#      "og:title" => "LinkExtractor",
#      "og:type" => "extractor",
#      "og:description" => "Extracts links from text",
#      "og:updated_time" => "2024-01-15T10:30:00Z",
#      "og:created_time" => "2024-01-15T10:30:00Z",
#      "og:category" => "text_processing",
#      "og:priority" => 1
#    }
```

### Custom OpenGraph Metadata

```ruby
component = RichTextExtraction::RegistryComponent.new(
  name: "AdvancedValidator",
  type: "validator",
  description: "Advanced validation component",
  metadata: {
    version: "2.0",
    author: "John Doe",
    tags: ["validation", "advanced"],
    dependencies: ["base_validator"]
  }
)

og_data = component.as_opengraph
# => {
#      "og:title" => "AdvancedValidator",
#      "og:type" => "validator",
#      "og:description" => "Advanced validation component",
#      "og:version" => "2.0",
#      "og:author" => "John Doe",
#      "og:tags" => ["validation", "advanced"],
#      "og:dependencies" => ["base_validator"]
#    }
```

## Registry Integration

### Automatic Registration

```ruby
# Components are automatically registered when saved
component = RichTextExtraction::RegistryComponent.new(
  name: "CustomExtractor",
  type: "extractor",
  class_name: "CustomExtractorClass"
)

component.save! # Automatically registers with RichTextExtraction::Registry

# Check registration
RichTextExtraction::Registry.exists?("CustomExtractor", "extractor") # => true
```

### Registry Queries

```ruby
# Get all components by type
extractors = RichTextExtraction::Registry.extractors
# => { "LinkExtractor" => LinkExtractorClass, "SocialExtractor" => SocialExtractorClass }

validators = RichTextExtraction::Registry.validators
# => { "UrlValidator" => UrlValidatorClass, "EmailValidator" => EmailValidatorClass }

# Find specific component
component = RichTextExtraction::Registry.find_by_name("LinkExtractor")
extractor_class = RichTextExtraction::Registry.get_extractor("LinkExtractor")
```

## Advanced Usage

### Custom Validations

```ruby
class CustomComponent < RichTextExtraction::RegistryComponent
  validates :name, format: { with: /\A[A-Z][a-zA-Z0-9]*\Z/, message: "must start with uppercase letter" }
  validates :metadata, presence: true
end

component = CustomComponent.new(name: "invalid-name", type: "extractor", class_name: "Class")
component.valid? # => false
component.errors.full_messages
# => ["Name must start with uppercase letter", "Metadata can't be blank"]
```

### Callbacks

```ruby
class LoggingComponent < RichTextExtraction::RegistryComponent
  after_save :log_registration
  
  private
  
  def log_registration
    Rails.logger.info "Component #{name} registered at #{Time.current}"
  end
end
```

### Batch Operations

```ruby
# Create multiple components
components = [
  { name: "Extractor1", type: "extractor", class_name: "Extractor1Class" },
  { name: "Validator1", type: "validator", class_name: "Validator1Class" },
  { name: "Helper1", type: "helper", class_name: "Helper1Class" }
]

components.each do |attrs|
  RichTextExtraction::RegistryComponent.create!(attrs)
end
```

## Error Handling

### Validation Errors

```ruby
begin
  component = RichTextExtraction::RegistryComponent.new(
    name: "", # Invalid: empty name
    type: "invalid_type" # Invalid: not in allowed list
  )
  component.save!
rescue ActiveModel::ValidationError => e
  puts "Validation failed: #{e.message}"
  puts component.errors.full_messages
end
```

### Registry Errors

```ruby
begin
  # Try to register duplicate component
  component1 = RichTextExtraction::RegistryComponent.create!(
    name: "Duplicate",
    type: "extractor",
    class_name: "Class1"
  )
  
  component2 = RichTextExtraction::RegistryComponent.create!(
    name: "Duplicate", # Same name and type
    type: "extractor",
    class_name: "Class2"
  )
rescue StandardError => e
  puts "Registration failed: #{e.message}"
end
```

## Best Practices

### Component Naming

```ruby
# Use descriptive, PascalCase names
RichTextExtraction::RegistryComponent.new(name: "LinkExtractor", ...)
RichTextExtraction::RegistryComponent.new(name: "UrlValidator", ...)
RichTextExtraction::RegistryComponent.new(name: "MarkdownHelper", ...)

# Avoid generic names
RichTextExtraction::RegistryComponent.new(name: "Extractor", ...) # Too generic
```

### Metadata Organization

```ruby
# Use structured metadata
component = RichTextExtraction::RegistryComponent.new(
  name: "AdvancedLinkExtractor",
  type: "extractor",
  class_name: "AdvancedLinkExtractorClass",
  metadata: {
    version: "1.2.0",
    category: "text_processing",
    priority: 1,
    dependencies: ["base_extractor"],
    tags: ["links", "advanced", "performance"],
    author: "Development Team",
    last_updated: "2024-01-15"
  }
)
```

### Association Management

```ruby
# Build logical hierarchies
main_extractor = RichTextExtraction::RegistryComponent.new(name: "MainExtractor", ...)
link_extractor = RichTextExtraction::RegistryComponent.new(name: "LinkExtractor", ...)
url_validator = RichTextExtraction::RegistryComponent.new(name: "UrlValidator", ...)

# Logical flow: Main -> Link -> URL Validation
main_extractor.add_child(link_extractor)
link_extractor.add_child(url_validator)

# Clean up when destroying
main_extractor.children.each(&:destroy!)
main_extractor.destroy!
```

## Performance Considerations

### Memory Management

```ruby
# Components are stored in memory, so be mindful of quantity
# Use appropriate cleanup
RichTextExtraction::Registry.all.each do |component|
  component.destroy! if component.inactive?
end
```

### Association Performance

```ruby
# Large hierarchies can impact performance
# Consider flattening if you have deep nesting
def flatten_hierarchy(component)
  [component] + component.children.flat_map { |child| flatten_hierarchy(child) }
end
```

## Integration Examples

### Rails Integration

```ruby
# In a Rails controller
class ComponentsController < ApplicationController
  def index
    @components = RichTextExtraction::RegistryComponent.by_type(params[:type])
  end
  
  def show
    @component = RichTextExtraction::RegistryComponent.find_by_name(params[:id])
    @og_data = @component.as_opengraph
  end
  
  def create
    @component = RichTextExtraction::RegistryComponent.new(component_params)
    if @component.save
      redirect_to @component, notice: 'Component created successfully'
    else
      render :new
    end
  end
  
  private
  
  def component_params
    params.require(:component).permit(:name, :type, :class_name, :description, metadata: {})
  end
end
```

### API Integration

```ruby
# JSON API response
def api_response(component)
  {
    id: component.name,
    type: component.type,
    attributes: component.attributes,
    relationships: {
      parent: component.parent&.name,
      children: component.children.map(&:name)
    },
    meta: {
      opengraph: component.as_opengraph,
      created_at: component.created_at,
      updated_at: component.updated_at
    }
  }
end
```

This comprehensive guide covers all aspects of the RegistryComponent, from basic usage to advanced features and best practices. 