# Contributing to RichTextExtraction

Thank you for your interest in contributing to RichTextExtraction! This document provides guidelines and information for contributors.

## 🚀 Quick Start

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🏗️ Project Architecture

RichTextExtraction follows a modern modular architecture:

```
lib/rich_text_extraction/
├── services/                    # Service classes
│   ├── opengraph_service.rb    # OpenGraph operations
│   └── markdown_service.rb     # Markdown rendering
├── extractors/                  # Focused extractors
│   ├── link_extractor.rb       # Link extraction
│   └── social_extractor.rb     # Social content
├── configuration.rb            # Configuration system
├── error.rb                    # Error handling
├── extractor.rb                # Main Extractor class
├── extracts_rich_text.rb       # Rails concern
├── helpers.rb                  # View helpers
├── instance_helpers.rb         # Instance helpers
├── markdown_helpers.rb         # Markdown helpers
├── opengraph_helpers.rb        # OpenGraph helpers
├── railtie.rb                  # Rails integration
└── version.rb                  # Version info
```

### Key Components

- **Service Classes**: Handle external operations (OpenGraph, Markdown)
- **Extractors**: Focused modules for specific content types
- **Configuration**: Centralized settings with sensible defaults
- **Helpers**: Rails integration and view helpers

## 🧪 Testing

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/extractor_spec.rb
bundle exec rspec spec/opengraph_helpers_spec.rb

# Run with coverage
bundle exec rspec --format documentation
```

### Test Organization

The test suite is organized by feature for maximum clarity:

- **Feature-focused files**: Each major module has its own spec file
- **Shared contexts**: Reusable test setup in `spec/support/shared_contexts.rb`
- **Advanced usage**: Split into granular files for complex scenarios
- **Placeholders**: Every module has a placeholder spec for future tests

### Test Best Practices

- Use descriptive example names
- Group related examples with `describe` blocks
- Use shared contexts for common setup
- Test both success and failure cases
- Use verifying doubles when appropriate
- Keep examples focused and atomic

### Adding New Tests

1. Create a new spec file in the appropriate directory
2. Use the existing shared contexts when possible
3. Follow the established naming conventions
4. Ensure comprehensive coverage of edge cases

## 📝 Code Style

### RuboCop Compliance

All code must pass RuboCop checks:

```bash
# Run RuboCop
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a
```

### YARD Documentation

All public methods must have YARD documentation:

```ruby
# @param text [String] The text to extract links from
# @return [Array<String>] Array of extracted URLs
# @example Extract links from text
#   extract_links("Visit https://example.com") # => ["https://example.com"]
def extract_links(text)
  # implementation
end
```

### Method Guidelines

- Keep methods focused and single-purpose
- Use descriptive method names
- Limit method complexity (cyclomatic complexity < 10)
- Keep methods under 20 lines when possible
- Use early returns to reduce nesting

## 🔧 Development Setup

### Prerequisites

- Ruby 3.1 or higher
- Rails 6.1 or higher (for Rails integration tests)
- Bundler

### Installation

```bash
# Clone the repository
git clone https://github.com/ceccec/rich_text_extraction.git
cd rich_text_extraction

# Install dependencies
bundle install

# Run tests to verify setup
bundle exec rspec
```

### Development Workflow

1. **Create a feature branch** from `main`
2. **Write tests first** (TDD approach)
3. **Implement the feature** following the architecture
4. **Update documentation** for any new public APIs
5. **Run the full test suite** to ensure nothing is broken
6. **Check code style** with RuboCop
7. **Generate documentation** with YARD
8. **Submit a pull request**

## 📚 Documentation

### Updating Documentation

- Update README.md for user-facing changes
- Update inline YARD documentation for API changes
- Update docs/ for significant feature additions
- Ensure all examples are current and working

### Generating Documentation

```bash
# Generate YARD documentation
bundle exec yard doc

# Generate docs site
cd docs && bundle exec jekyll build
```

## 🚀 Adding New Features

### Service Classes

When adding new external operations:

```ruby
# lib/rich_text_extraction/services/new_service.rb
module RichTextExtraction
  class NewService
    def initialize(options = {})
      @options = options
    end
    
    def process(data)
      # Implementation
    end
    
    private
    
    attr_reader :options
  end
end
```

### Extractors

When adding new content extraction:

```ruby
# lib/rich_text_extraction/extractors/new_extractor.rb
module RichTextExtraction
  module NewExtractor
    def extract_new_content(text)
      # Implementation
    end
    
    private
    
    def validate_new_content(content)
      # Validation logic
    end
  end
end
```

### Configuration

When adding new configuration options:

```ruby
# lib/rich_text_extraction/configuration.rb
def new_option=(value)
  @new_option = value
end

def new_option
  @new_option ||= default_value
end
```

## 🐛 Bug Reports

When reporting bugs, please include:

1. **Ruby version** and **Rails version** (if applicable)
2. **Steps to reproduce** the issue
3. **Expected behavior** vs **actual behavior**
4. **Error messages** and stack traces
5. **Code examples** that demonstrate the issue

## 💡 Feature Requests

When requesting features, please include:

1. **Use case** and **motivation**
2. **Proposed API** or interface
3. **Implementation suggestions** (if any)
4. **Examples** of how it would be used

## 🔄 Pull Request Process

1. **Fork the repository** and create a feature branch
2. **Write comprehensive tests** for your changes
3. **Follow the existing code style** and architecture
4. **Update documentation** for any new features
5. **Ensure all tests pass** and RuboCop is clean
6. **Write a clear commit message** describing your changes
7. **Submit the pull request** with a detailed description

### Pull Request Guidelines

- **Title**: Clear, descriptive title
- **Description**: Detailed explanation of changes
- **Tests**: Include tests for new functionality
- **Documentation**: Update relevant documentation
- **Breaking changes**: Clearly mark and explain

## 📋 Code Review Process

1. **Automated checks** must pass (tests, RuboCop)
2. **Code review** by maintainers
3. **Address feedback** and make requested changes
4. **Final approval** and merge

## 🏷️ Versioning

RichTextExtraction follows [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## 📄 License

By contributing to RichTextExtraction, you agree that your contributions will be licensed under the MIT License.

## 🆘 Getting Help

- **Issues**: [GitHub Issues](https://github.com/ceccec/rich_text_extraction/issues)
- **Documentation**: [Docs Site](https://ceccec.github.io/rich_text_extraction/)
- **API Reference**: [API Docs](https://ceccec.github.io/rich_text_extraction/api-reference/)

---

Thank you for contributing to RichTextExtraction! 🚀 