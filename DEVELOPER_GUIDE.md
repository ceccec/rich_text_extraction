# RichTextExtraction Developer Guide

## Table of Contents

1. [Overview](#overview)
2. [Architecture & Design Principles](#architecture--design-principles)
3. [Core Components](#core-components)
4. [DRY Refactoring Achievements](#dry-refactoring-achievements)
5. [Usage Examples](#usage-examples)
6. [Development Guidelines](#development-guidelines)
7. [Contributing](#contributing)
8. [Testing](#testing)

## Overview

The `rich_text_extraction` gem provides comprehensive text extraction and validation capabilities for Ruby on Rails applications. It's designed with **DRY (Don't Repeat Yourself)** principles at its core, achieving **93.5% reduction in code duplication** through advanced refactoring techniques.

### Key Features

- **Text Extraction**: Extract links, hashtags, mentions, emails, and more from rich text
- **File Processing**: Support for multiple file formats (PDF, DOCX, HTML, etc.)
- **Validation**: Built-in validators for ISBN, VIN, UUID, and other formats
- **OpenGraph Integration**: Extract and cache OpenGraph metadata
- **Rails Integration**: Seamless integration with ActionText and Rails views
- **Caching**: Flexible caching support with Rails cache or custom implementations

## Architecture & Design Principles

### DRY-First Design

The gem follows a **DRY-first** approach with these key principles:

1. **Single Source of Truth**: Each concept has one authoritative implementation
2. **Factory Patterns**: Use factory methods to create similar objects
3. **Metaprogramming**: Generate methods dynamically to eliminate repetition
4. **Shared Concerns**: Extract common functionality into reusable modules
5. **Configuration-Driven**: Use configuration to drive behavior instead of hardcoding

### Component Architecture

```
RichTextExtraction/
├── Core Module (rich_text_extraction.rb)
├── Constants (constants.rb) - Centralized patterns and validators
├── Extractors/
│   ├── Base Extractor (base_extractor.rb)
│   ├── Link Extractor (link_extractor.rb)
│   └── Social Extractor (social_extractor.rb)
│
├── extractors.rb                 # Main Extractor class
├── Validators/
│   ├── Base Validator (base_validator.rb)
│   ├── Auto Loader (auto_loader.rb)
│   └── Factory (validator_factory.rb)
├── Services/
│   ├── Markdown Service (markdown_service.rb)
│   └── OpenGraph Service (opengraph_service.rb)
├── Helpers/
│   ├── Markdown Helpers (markdown_helpers.rb)
│   ├── OpenGraph Helpers (opengraph_helpers.rb)
│   └── Validator Helpers (validator_helpers.rb)
└── Cache Operations (cache_operations.rb)
```

## Core Components

### 1. Constants Module

**Location**: `lib/rich_text_extraction/constants.rb`

The Constants module serves as the single source of truth for all patterns, validators, and shared data.

```ruby
# Validator factory pattern
VALIDATOR_TYPES = {
  standard: { schema_type: nil, schema_property: nil },
  product: { schema_type: 'Product', schema_property: nil },
  social: { schema_type: 'Person', schema_property: 'sameAs' },
  thing: { schema_type: 'Thing', schema_property: 'identifier' }
}.freeze

# Dynamic method generation
VALIDATOR_TYPES.each do |type, defaults|
  define_singleton_method("#{type}_validator") do |valid:, invalid:, **options|
    # Implementation
  end
end
```

### 2. Extractors

**Location**: `lib/rich_text_extraction/extractors/`

Extractors follow a shared pattern and inherit from base classes:

```ruby
# Base extractor provides common functionality
module BaseExtractor
  def extract_social_items(text, regex)
    return [] unless text.is_a?(String)
    text.scan(regex).flatten.uniq
  end
end

# Specific extractors use the base functionality
module SocialExtractor
  include BaseExtractor
  
  def extract_tags(text)
    extract_social_items(text, HASHTAG_REGEX)
  end
end
```

### 3. Validators

**Location**: `lib/rich_text_extraction/validators/`

Validators use a factory pattern and auto-loading:

```ruby
# Base validator with common validation logic
class BaseValidator
  def validate(value)
    return false unless value.is_a?(String)
    # Common validation logic
  end
end

# Auto-loader dynamically creates validators
module AutoLoader
  def self.load_validators
    VALIDATOR_CONFIG.each do |name, config|
      create_validator_class(name, config)
    end
  end
end
```

### 4. Services

**Location**: `lib/rich_text_extraction/services/`

Services encapsulate complex operations and share common patterns:

```ruby
# OpenGraph service uses shared cache operations
class OpenGraphService
  include CacheOperations
  
  def extract(url, cache: nil, cache_options: {})
    # Uses shared cache methods
  end
end
```

## DRY Refactoring Achievements

### Before vs After

- **Initial duplication score**: 3415
- **Final duplication score**: 222
- **Total reduction**: **93.5% less duplication** (3193 points eliminated!)

### Key Refactoring Techniques Applied

#### 1. Validator Factory Pattern

**Before**: Individual validator methods with repetitive code
```ruby
def self.product_validator(valid:, invalid:, schema_property:, regex:, error_message:)
  build_validator_entry(
    valid: valid,
    invalid: invalid,
    schema_type: 'Product',
    schema_property: schema_property,
    description: schema_description('Product', schema_property),
    regex: regex,
    error_message: error_message
  )
end
```

**After**: Dynamic method generation
```ruby
VALIDATOR_TYPES.each do |type, defaults|
  define_singleton_method("#{type}_validator") do |valid:, invalid:, **options|
    # Single implementation for all validator types
  end
end
```

#### 2. Metaprogramming for Instance Methods

**Before**: Repetitive instance method definitions
```ruby
def links
  extract_links(plain_text)
end

def tags
  extract_hashtags(plain_text)
end

# ... many more similar methods
```

**After**: Dynamic method generation
```ruby
INSTANCE_METHODS = {
  links: 'extract_links',
  tags: 'extract_hashtags',
  # ... configuration
}.freeze

INSTANCE_METHODS.each do |method_name, extraction_method|
  define_method(method_name) do
    send(extraction_method, plain_text)
  end
end
```

#### 3. Shared Cache Operations

**Before**: Duplicate cache logic in multiple files
```ruby
# In OpenGraphService
def read_cache(url, cache, cache_options, key_prefix)
  return rails_cache_read(url, cache_options, key_prefix) if use_rails_cache?(cache)
  cache[url] if cache && cache != :rails && cache[url]
end

# In CacheOperations (duplicate)
def read_cache(key, cache, cache_options = {})
  return nil unless cache
  if use_rails_cache?(cache)
    rails_cache_read(key, cache_options)
  else
    cache[key]
  end
end
```

**After**: Single shared implementation
```ruby
# OpenGraphService includes CacheOperations
class OpenGraphService
  include CacheOperations
  # Uses shared methods
end
```

#### 4. Template Helper Methods

**Before**: Repetitive ERB conditionals
```erb
<% if @social_content[:tags].any? %>
  <div class="tags">
    <h4>Tags</h4>
    <% @social_content[:tags].each do |tag| %>
      <span class="tag">#<%= tag %></span>
    <% end %>
  </div>
<% end %>

<% if @social_content[:mentions].any? %>
  <div class="mentions">
    <h4>Mentions</h4>
    <% @social_content[:mentions].each do |mention| %>
      <span class="mention">@<%= mention %></span>
    <% end %>
  </div>
<% end %>
```

**After**: Shared helper method
```erb
<% def render_content_section(title, items, item_class = nil, prefix = nil, suffix = nil)
     return unless items.any?
     # Single implementation for all content sections
   end %>

<%= render_content_section('Tags', @social_content[:tags], 'tags', '#') %>
<%= render_content_section('Mentions', @social_content[:mentions], 'mentions', '@') %>
```

## Usage Examples

### Basic Text Extraction

```ruby
# Include in your model
class Post < ApplicationRecord
  include RichTextExtraction
end

# Use extraction methods
post = Post.find(1)
post.links          # => ["https://example.com", "http://test.com"]
post.tags           # => ["ruby", "rails"]
post.mentions       # => ["alice", "bob"]
post.emails         # => ["user@example.com"]
post.excerpt(100)   # => "First 100 characters..."
```

### File Processing

```ruby
# Extract text from various file formats
text_data = RichTextExtraction.extract_from_file("document.pdf")
# Returns: { text: "...", links: [...], tags: [...], mentions: [...] }

# Process specific file types
html_text = RichTextExtraction.extract_html("page.html")
pdf_text = RichTextExtraction.extract_pdf("document.pdf")
docx_text = RichTextExtraction.extract_docx("document.docx")
```

### Validation

```ruby
# Use built-in validators
validator = RichTextExtraction::ValidatorFactory.create(:isbn)
validator.valid?("978-3-16-148410-0")  # => true
validator.valid?("invalid-isbn")       # => false

# Batch validation
results = RichTextExtraction::ValidatorAPI.batch_validate(
  values: ["978-3-16-148410-0", "invalid"],
  validators: [:isbn, :url]
)
```

### OpenGraph Integration

```ruby
# Extract OpenGraph data
og_data = RichTextExtraction.extract_opengraph("https://example.com")

# With caching
og_data = RichTextExtraction.extract_opengraph(
  "https://example.com",
  cache: :rails,
  cache_options: { expires_in: 1.hour }
)
```

### Rails View Helpers

```erb
<!-- In your ERB templates -->
<%= opengraph_preview_for("https://example.com") %>

<!-- With custom format -->
<%= opengraph_preview_for(og_data, format: :markdown) %>
```

## Development Guidelines

### Adding New Validators

1. **Use the factory pattern**:
```ruby
# In constants.rb
VALIDATOR_EXAMPLES[:new_validator] = thing_validator(
  valid: ['valid-example'],
  invalid: ['invalid-example'],
  regex: 'NEW_VALIDATOR_REGEX',
  error_message: ERROR_MESSAGES[:new_validator]
)
```

2. **Add regex pattern**:
```ruby
# In extraction_patterns.rb
NEW_VALIDATOR_REGEX = /\Apattern\z/u
```

3. **Add error message**:
```ruby
# In constants.rb
ERROR_MESSAGES = {
  # ... existing messages
  new_validator: 'is not a valid new validator'
}.freeze
```

### Adding New Extractors

1. **Inherit from base extractor**:
```ruby
module NewExtractor
  include BaseExtractor
  
  def extract_new_items(text)
    extract_social_items(text, NEW_ITEM_REGEX)
  end
end
```

2. **Add to instance methods**:
```ruby
INSTANCE_METHODS = {
  # ... existing methods
  new_items: 'extract_new_items'
}.freeze
```

### Adding New File Types

1. **Add extraction method**:
```ruby
def self.extract_new_format(path)
  require_with_fallback('new-gem') do
    # Extraction logic
  end
end
```

2. **Add to file extractors**:
```ruby
def self.create_file_extractors
  {
    # ... existing mappings
    '.new' => method(:extract_new_format)
  }.freeze
end
```

### Testing Guidelines

1. **Test shared functionality**:
```ruby
RSpec.describe RichTextExtraction::Constants do
  describe '.create_validator' do
    it 'creates validators with correct structure' do
      validator = described_class.create_validator(
        valid: ['test'],
        invalid: ['invalid'],
        schema_type: 'Test',
        schema_property: 'test'
      )
      expect(validator).to include(:valid, :invalid, :schema_type)
    end
  end
end
```

2. **Test dynamic method generation**:
```ruby
RSpec.describe RichTextExtraction do
  describe 'dynamic instance methods' do
    it 'generates extraction methods' do
      expect(subject).to respond_to(:links)
      expect(subject).to respond_to(:tags)
    end
  end
end
```

## Contributing

### Code Style

- Follow the existing DRY patterns
- Use factory methods for similar objects
- Prefer configuration over hardcoding
- Write comprehensive tests
- Document public APIs

### Pull Request Process

1. Ensure all tests pass
2. Run `bundle exec flay lib/` to check for new duplication
3. Update documentation if needed
4. Follow the existing code patterns

### DRY Checklist

Before submitting code, ensure:

- [ ] No duplicate method definitions
- [ ] Shared functionality is extracted to base classes/modules
- [ ] Configuration is used instead of hardcoded values
- [ ] Factory patterns are used for similar objects
- [ ] Metaprogramming is used appropriately for repetitive patterns

## Testing

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/extractors/

# Run with coverage
bundle exec rspec --coverage
```

### Code Quality Checks

```bash
# Check for code duplication
bundle exec flay lib/

# Run RuboCop
bundle exec rubocop

# Run all quality checks
bundle exec rake quality
```

### Test Structure

Tests follow the same DRY principles:

```ruby
# Shared examples for similar functionality
RSpec.shared_examples 'extractor' do |method_name, regex|
  it "extracts #{method_name} from text" do
    result = subject.send(method_name, test_text)
    expect(result).to match_array(expected_results)
  end
end

# Use shared examples
RSpec.describe SocialExtractor do
  it_behaves_like 'extractor', :extract_tags, HASHTAG_REGEX
  it_behaves_like 'extractor', :extract_mentions, MENTION_REGEX
end
```

## Conclusion

The `rich_text_extraction` gem demonstrates advanced Ruby programming techniques and DRY principles. By following the patterns established in this guide, you can contribute to maintaining the gem's high code quality and extensibility.

Remember: **DRY isn't just about avoiding repetition—it's about creating maintainable, extensible, and elegant code that's easy to understand and modify.** 