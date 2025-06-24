# Contributing to RichTextExtraction

Thank you for your interest in contributing! This project uses a **doc-driven, self-learning, DRY workflow** to ensure maximum maintainability and developer happiness.

## 🚀 Quick Start

1. **Fork** the repository
2. **Clone** your fork: `git clone https://github.com/ceccec/rich_text_extraction.git`
3. **Install** dependencies: `bundle install`
4. **Run tests** to ensure everything works: `bundle exec rspec`
5. **Create** a feature branch: `git checkout -b feature/your-feature-name`
6. **Make** your changes
7. **Test** your changes: `bundle exec rspec && bundle exec rubocop`
8. **Commit** with a descriptive message
9. **Push** to your fork
10. **Open** a Pull Request

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

### Current Test Status

- **44 examples, 0 failures** - All tests pass
- **32.36 seconds** - Fast execution time
- **100% pass rate** - Reliable test suite

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run with documentation format
bundle exec rspec --format documentation

# Run a specific test file
bundle exec rspec spec/extractor_spec.rb

# Run RuboCop for code quality
bundle exec rubocop

# Run both tests and linting
bundle exec rspec && bundle exec rubocop
```

### Test Suite Organization

The test suite is organized into focused files:

- `spec/core_functionality_spec.rb` - Core gem functionality
- `spec/extractor_spec.rb` - Main extractor class
- `spec/opengraph_helpers_spec.rb` - OpenGraph functionality
- `spec/markdown_helpers_spec.rb` - Markdown rendering
- `spec/rails_integration_spec.rb` - Rails integration
- `spec/advanced_*.rb` - Advanced usage scenarios

### Test Best Practices

- Use **descriptive example names** that explain the behavior
- Group related examples with `describe` and `context` blocks
- Use **shared contexts** from `spec/support/shared_contexts.rb` for common setup
- Test both **success and failure cases**
- Use **verifying doubles** for mocks/stubs
- Keep examples **focused and atomic**

For detailed testing information, see [docs/testing.md](docs/testing.md).

## 📝 Code Style

### RuboCop

We use RuboCop to maintain consistent code style. All code must pass RuboCop checks:

```bash
bundle exec rubocop
```

### Style Guidelines

- Use **2 spaces** for indentation
- Use **snake_case** for methods and variables
- Use **CamelCase** for classes and modules
- Use **UPPER_CASE** for constants
- Prefer **single quotes** for strings unless interpolation is needed
- Add **trailing commas** in multi-line arrays and hashes
- Use **guard clauses** instead of nested conditionals when possible

### Documentation

- All **public methods** must have YARD documentation
- Include **@param** and **@return** tags for method documentation
- Add **@example** tags for complex methods
- Use **@since** tags for new features

Example:

```ruby
# @param text [String] The text to extract links from
# @param options [Hash] Extraction options
# @option options [Boolean] :with_opengraph Whether to fetch OpenGraph data
# @return [Array<Hash>] Array of link objects with metadata
# @example Extract links with OpenGraph data
#   extractor = RichTextExtraction::Extractor.new("Visit https://example.com")
#   extractor.link_objects(with_opengraph: true)
#   # => [{ url: "https://example.com", opengraph: { title: "Example" } }]
def link_objects(text, options = {})
  # implementation
end
```

## 🏗️ Architecture Guidelines

### Adding New Features

1. **Create** a new module or class in the appropriate directory
2. **Add** comprehensive tests
3. **Update** documentation
4. **Add** configuration options if needed
5. **Update** the main module to include new functionality

### Module Structure

```
lib/rich_text_extraction/
├── services/           # Service classes (OpenGraphService, MarkdownService)
├── extractors/         # Focused extractors (LinkExtractor, SocialExtractor)
├── helpers.rb          # View and instance helpers
├── configuration.rb    # Configuration system
└── railtie.rb         # Rails integration
```

### Service Classes

Service classes should:
- Be **focused** on a single responsibility
- Accept **configuration options**
- Handle **errors gracefully**
- Be **testable** and **mockable**

Example:

```ruby
module RichTextExtraction
  class ExampleService
    def initialize(options = {})
      @options = RichTextExtraction.configuration.merge(options)
    end

    def process(input)
      # implementation
    rescue StandardError => e
      handle_error(e)
    end

    private

    def handle_error(error)
      # error handling
    end
  end
end
```

## 🔧 Development Setup

### Prerequisites

- Ruby 3.1 or higher
- Bundler
- Git

### Setup Commands

```bash
# Clone the repository
git clone https://github.com/ceccec/rich_text_extraction.git
cd rich_text_extraction

# Install dependencies
bundle install

# Run tests to verify setup
bundle exec rspec

# Generate documentation
bundle exec yard doc

# Build the gem
gem build rich_text_extraction.gemspec
```

### Development Dependencies

The project includes several development dependencies:

- **RSpec** - Testing framework
- **RuboCop** - Code linting
- **YARD** - Documentation generation
- **Jekyll** - Documentation site
- **GitHub Actions** - CI/CD

## 📚 Documentation

### Updating Documentation

1. **Update** inline YARD documentation for code changes
2. **Update** README.md for user-facing changes
3. **Update** docs/ files for detailed documentation
4. **Regenerate** documentation: `bundle exec yard doc`

### Documentation Structure

```
docs/
├── _posts/           # Blog posts and tutorials
├── api/              # Auto-generated API documentation
├── assets/           # Images and diagrams
├── testing.md        # Testing guide
└── index.markdown    # Main documentation page
```

## 🚀 Release Process

### Version Bumping

1. **Update** version in `lib/rich_text_extraction/version.rb`
2. **Update** version in `rich_text_extraction.gemspec`
3. **Update** CHANGELOG.md with new features and fixes
4. **Commit** version bump: `git commit -m "Bump version to X.Y.Z"`

### Publishing

1. **Build** the gem: `gem build rich_text_extraction.gemspec`
2. **Test** the gem locally
3. **Push** to RubyGems: `gem push rich_text_extraction-X.Y.Z.gem`
4. **Create** a GitHub release

## 🐛 Bug Reports

When reporting bugs, please include:

1. **Ruby version** and **Rails version** (if applicable)
2. **Gem version** you're using
3. **Error message** and **stack trace**
4. **Steps to reproduce** the issue
5. **Expected behavior** vs **actual behavior**

## 💡 Feature Requests

When requesting features, please include:

1. **Use case** and **motivation**
2. **Proposed API** or interface
3. **Example usage** code
4. **Considerations** for implementation

## 🤝 Pull Request Guidelines

### Before Submitting

1. **Run tests**: `bundle exec rspec`
2. **Check style**: `bundle exec rubocop`
3. **Generate docs**: `bundle exec yard doc`
4. **Update documentation** if needed
5. **Add tests** for new features
6. **Update CHANGELOG.md** for user-facing changes

### PR Description

Include:
- **Summary** of changes
- **Motivation** for the change
- **Testing** performed
- **Breaking changes** (if any)
- **Related issues**

### Review Process

1. **Automated checks** must pass (tests, RuboCop)
2. **Code review** by maintainers
3. **Documentation** review
4. **Merge** after approval

## 📄 License

By contributing to RichTextExtraction, you agree that your contributions will be licensed under the MIT License.

## 🆘 Getting Help

- **Issues**: [GitHub Issues](https://github.com/ceccec/rich_text_extraction/issues)
- **Documentation**: [Docs Site](https://ceccec.github.io/rich_text_extraction/)
- **Discussions**: [GitHub Discussions](https://github.com/ceccec/rich_text_extraction/discussions)

## Test & Quality Status (June 2025)

- **RSpec:** 44 examples, 0 failures
- **RuboCop:** No offenses detected
- **YARD:** 85.86% documented, a few dynamic mixin warnings (expected for Rails mixins)
- **Gem build:** No gemspec self-inclusion error (fixed June 2025)

### Generator Testing

- Generator tests use Minitest and are located in `test/generators/`.
- Use `Rails::Generators::TestCase` for new generator tests.
- Run with `bundle exec rake test`.

### Generator Test Organization

- Each generated file (initializer, configuration, model, controller, view, job, routes, README) has its own dedicated test in `test/generators/rich_text_extraction/install/`.
- To add a test for a new generator feature, create a new test file in this directory.
- Each test file should focus on a single generated file or feature.
- Run all generator tests with:
  ```sh
  bundle exec rake test
  ```

### Static Analysis Exclusions

- Generator templates (`lib/generators/rich_text_extraction/install/templates/`) are excluded from RuboCop and YARD checks because they are ERB templates, not valid Ruby until rendered.
- See `.rubocop.yml` and `.yardopts` for exclusion rules.

## 🚦 Quick Checklist for Adding or Updating a Validator

1. **Edit the Source of Truth:**
   - Open `lib/rich_text_extraction/constants.rb`.
   - Add or update the entry in `VALIDATOR_EXAMPLES`:
     - `valid`: Array of valid examples
     - `invalid`: Array of invalid examples
     - `regex`: (Optional) Name of the regex constant in `ExtractionPatterns` (as a string)
     - `schema_type`, `schema_property`, `description`, `error_message`: (Optional) Metadata for docs and API

2. **(Optional) Add a Regex:**
   - If your validator is pattern-based, add the regex constant to `lib/rich_text_extraction/extraction_patterns.rb`.

3. **Custom Logic?**
   - If your validator needs custom logic (e.g., ISBN, VIN), implement the validator class in `lib/rich_text_extraction/validators/`.
   - Reference it in `VALIDATOR_EXAMPLES` and add to the skip list in the metaprogramming block if needed.

4. **Run Automation:**
   - Run `rake docs:all` to regenerate documentation.
   - Run `rake test:scenarios_from_docs` to run doc-driven tests.
   - Run `rake` or `rake test` to run all quality checks and tests.

5. **Check the Results:**
   - If you see a failure about a missing validator, either add a regex (for pattern-based) or implement the custom logic class.
   - If you see a drift/gap warning, ensure your docs, code, and tests are in sync.

6. **Open a Pull Request:**
   - Commit your changes and open a PR. CI will run all checks automatically.

## 🧠 How the System Works (Self-Learning, DRY, Doc-Driven)

- **Single Source of Truth:** All validator logic, examples, and docs are driven from `VALIDATOR_EXAMPLES`.
- **Docs, API, and tests are auto-generated** from this source. No need to update multiple places.
- **Doc-driven tests** ensure all examples in the docs are tested. If a validator is missing, the system will auto-generate a stub (for regex types) or fail with a clear message.
- **Drift/gap detection**: If docs, code, or tests are out of sync, CI will fail and report the issue.

## 🛠️ Drift/Gap Detection & CI Failures

- **Missing Validator:** If you add a new validator to the docs but don't implement it, the test runner will:
  - Auto-generate a stub for regex-based types.
  - Fail with a clear message for custom logic types.
- **Drift Detected:** If docs, code, or tests are out of sync, CI will fail. Run the automation steps above to fix.
- **Coverage Gaps:** The summary report after tests will list any missing or untested features.

## 📝 Example: Adding a New Validator

1. In `lib/rich_text_extraction/constants.rb`:
   ```ruby
   VALIDATOR_EXAMPLES[:foo_code] = {
     valid: ['FOO123'],
     invalid: ['BAR456'],
     regex: 'FOO_CODE_REGEX',
     error_message: 'is not a valid FOO code',
     schema_type: 'Thing',
     schema_property: 'identifier',
     description: 'FOO code (custom example)'
   }
   ```
2. In `lib/rich_text_extraction/extraction_patterns.rb`:
   ```ruby
   FOO_CODE_REGEX = /FOO\d{3}/
   ```
3. Run `rake docs:all` and `rake test:scenarios_from_docs`.
4. If all tests pass, you're done!

## 💡 Tips
- **Never edit the docs or tests directly for validators.** Always update the source hash.
- **If in doubt, run `rake` and read the output.**
- **For advanced features, see the README and usage guide.**

---

Happy contributing! 🎉 