---
layout: page
title: Testing
permalink: /testing.html
---

# 🧪 Testing RichTextExtraction

This page is the single source of truth for the test suite organization, best practices, and usage in the RichTextExtraction gem.

## 🏗️ Test Suite Structure

- **Feature-focused files:** Each major module (extractors, services, helpers, etc.) has its own spec file in `spec/`.
- **Shared contexts:** Common setup and reusable test logic are in `spec/support/shared_contexts.rb`.
- **Advanced usage:** Complex or integration scenarios are split into granular files.
- **Placeholders:** Every module has a placeholder spec for future tests, ensuring coverage as the project grows.

## 🚦 Running Tests

```bash
# Run all tests
bundle exec rspec

# Run a specific test file
bundle exec rspec spec/extractor_spec.rb
bundle exec rspec spec/opengraph_helpers_spec.rb

# Run with documentation format
bundle exec rspec --format documentation

# Run with coverage
bundle exec rspec --format documentation
```

## 📊 Current Test Status

- **35 examples, 0 failures** - All tests pass
- **1.23 seconds** - Fast execution time
- **Feature coverage** - Tests cover all major functionality:
  - ActionText integration
  - Background jobs
  - Cache usage
  - Error handling
  - Extractor functionality
  - View helpers
  - Rails integration

## 📝 Best Practices

- **Descriptive example names:** Use clear, intention-revealing descriptions for each test.
- **Group related examples:** Use `describe` and `context` blocks to organize tests logically.
- **Shared contexts:** Use `include_context` for common setup.
- **Atomic tests:** Keep each example focused on a single behavior.
- **Verifying doubles:** Use RSpec verifying doubles for mocks/stubs.
- **Test both success and failure cases.**
- **Keep examples short and focused.**

## 🔍 Verifying Doubles

Verifying doubles ensure that your mocks and stubs match the actual interface of the objects they're replacing. This prevents tests from passing when the real implementation changes.

### Instance Doubles

```ruby
# Good: Verifying double that matches the actual interface
RSpec.describe RichTextExtraction::Extractor do
  let(:cache_service) { instance_double(RichTextExtraction::OpenGraphService) }
  
  before do
    allow(RichTextExtraction::OpenGraphService).to receive(:new).and_return(cache_service)
    allow(cache_service).to receive(:extract).with('https://example.com', any_args)
      .and_return({ title: 'Example Site' })
  end
  
  it 'uses the cache service for OpenGraph extraction' do
    extractor = RichTextExtraction::Extractor.new('https://example.com')
    result = extractor.link_objects(with_opengraph: true)
    
    expect(cache_service).to have_received(:extract).with('https://example.com', any_args)
    expect(result.first[:opengraph][:title]).to eq('Example Site')
  end
end
```

### Class Doubles

```ruby
# Good: Verifying class double
RSpec.describe RichTextExtraction::MarkdownService do
  let(:renderer_class) { class_double(Redcarpet::Markdown) }
  let(:renderer_instance) { instance_double(Redcarpet::Markdown) }
  
  before do
    stub_const('Redcarpet::Markdown', renderer_class)
    allow(renderer_class).to receive(:new).and_return(renderer_instance)
    allow(renderer_instance).to receive(:render).and_return('<p>Rendered HTML</p>')
  end
  
  it 'uses Redcarpet for markdown rendering' do
    service = RichTextExtraction::MarkdownService.new
    result = service.render('**Bold text**')
    
    expect(renderer_instance).to have_received(:render).with('**Bold text**')
    expect(result).to eq('<p>Rendered HTML</p>')
  end
end
```

### Object Doubles

```ruby
# Good: Verifying object double for external dependencies
RSpec.describe RichTextExtraction::OpenGraphService do
  let(:http_client) { object_double(Net::HTTP) }
  
  before do
    allow(Net::HTTP).to receive(:get_response).and_return(http_client)
    allow(http_client).to receive(:body).and_return('<html><title>Test Site</title></html>')
  end
  
  it 'fetches OpenGraph data from external URLs' do
    service = RichTextExtraction::OpenGraphService.new
    result = service.extract('https://example.com')
    
    expect(Net::HTTP).to have_received(:get_response)
    expect(result[:title]).to eq('Test Site')
  end
end
```

### Best Practices for Verifying Doubles

1. **Use instance_double for instance methods**
2. **Use class_double for class methods**
3. **Use object_double for external dependencies**
4. **Always verify that the double matches the real interface**
5. **Test the behavior, not the implementation**

## 🔄 Shared Contexts

Shared contexts help you avoid code duplication and make tests more maintainable by providing reusable setup and helper methods.

### Basic Shared Context

```ruby
# spec/support/shared_contexts.rb
RSpec.shared_context 'with sample text' do
  let(:sample_text) { 'Visit https://example.com and check out #ruby' }
  let(:sample_links) { ['https://example.com'] }
  let(:sample_tags) { ['ruby'] }
  let(:sample_mentions) { [] }
end

RSpec.shared_context 'with OpenGraph service' do
  let(:og_service) { instance_double(RichTextExtraction::OpenGraphService) }
  
  before do
    allow(RichTextExtraction::OpenGraphService).to receive(:new).and_return(og_service)
  end
end

RSpec.shared_context 'with cache service' do
  let(:cache) { double('cache') }
  
  before do
    allow(cache).to receive(:read)
    allow(cache).to receive(:write)
    allow(cache).to receive(:delete)
  end
end
```

### Using Shared Contexts

```ruby
# In your spec file
RSpec.describe RichTextExtraction::Extractor do
  include_context 'with sample text'
  include_context 'with OpenGraph service'
  
  it 'extracts links from text' do
    extractor = described_class.new(sample_text)
    expect(extractor.links).to eq(sample_links)
  end
  
  it 'extracts tags from text' do
    extractor = described_class.new(sample_text)
    expect(extractor.tags).to eq(sample_tags)
  end
  
  context 'with OpenGraph data' do
    before do
      allow(og_service).to receive(:extract).and_return({ title: 'Example' })
    end
    
    it 'fetches OpenGraph metadata' do
      extractor = described_class.new(sample_text)
      result = extractor.link_objects(with_opengraph: true)
      
      expect(og_service).to have_received(:extract)
      expect(result.first[:opengraph][:title]).to eq('Example')
    end
  end
end
```

### Advanced Shared Contexts

```ruby
# spec/support/shared_contexts.rb
RSpec.shared_context 'with Rails environment' do
  let(:rails_cache) { double('Rails.cache') }
  
  before do
    stub_const('Rails', double('Rails', cache: rails_cache))
    allow(rails_cache).to receive(:fetch)
    allow(rails_cache).to receive(:write)
    allow(rails_cache).to receive(:delete)
  end
end

RSpec.shared_context 'with ActionText model' do
  let(:post_class) do
    Class.new do
      include RichTextExtraction::ExtractsRichText
      attr_accessor :body
      
      def initialize(body_content)
        @body = double('ActionText::RichText', to_plain_text: body_content)
      end
    end
  end
  
  let(:post) { post_class.new('Visit https://example.com') }
end
```

## 🚀 CI/CD Integration

The RichTextExtraction project uses GitHub Actions for continuous integration and deployment.

### GitHub Actions Workflow

```yaml
# .github/workflows/main.yml
name: Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        ruby-version: ['3.1', '3.2', '3.3']
        rails-version: ['6.1', '7.0', '7.1']
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: ${{ matrix.ruby-version }}
        bundler-cache: true
    
    - name: Install dependencies
      run: |
        gem install bundler
        bundle install
    
    - name: Run tests
      run: bundle exec rspec
    
    - name: Run RuboCop
      run: bundle exec rubocop
    
    - name: Generate documentation
      run: bundle exec yard doc
    
    - name: Build docs site
      run: |
        cd docs
        bundle install
        bundle exec jekyll build
```

### CI Best Practices

1. **Matrix Testing:** Test against multiple Ruby and Rails versions
2. **Caching:** Cache dependencies to speed up builds
3. **Parallel Jobs:** Run tests, linting, and docs generation in parallel
4. **Status Checks:** Require CI to pass before merging PRs
5. **Coverage Reports:** Track test coverage over time

### Local CI Simulation

```bash
# Run the same checks locally that CI runs
bundle exec rspec
bundle exec rubocop
bundle exec yard doc
cd docs && bundle exec jekyll build
```

### Pre-commit Hooks

Consider using pre-commit hooks to catch issues before pushing:

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running tests..."
bundle exec rspec

echo "Running RuboCop..."
bundle exec rubocop

echo "Generating documentation..."
bundle exec yard doc

echo "All checks passed!"
```

## 🧹 Linting & Quality

- **RuboCop:** All specs are checked with `rubocop-rspec` for style and best practices.
- **YARD:** All public methods are documented, and examples are included in the docs.

## 📚 Documentation & References

- The test suite structure and best practices are documented here.
- The README, CONTRIBUTING.md, and docs site all reference this central test documentation for DRYness.

## 🧩 Adding New Tests

1. Create a new spec file for the feature/module in `spec/`.
2. Use shared contexts from `spec/support/shared_contexts.rb` if needed.
3. Follow naming conventions and best practices.
4. Test both typical and edge cases.
5. Run the full suite to ensure nothing is broken.

## 🏷️ Example: Complete Test File

```ruby
# spec/extractor_spec.rb
RSpec.describe RichTextExtraction::Extractor do
  include_context 'with sample text'
  include_context 'with OpenGraph service'
  
  let(:extractor) { described_class.new(sample_text) }
  
  describe '#links' do
    it 'extracts URLs from text' do
      expect(extractor.links).to eq(sample_links)
    end
    
    it 'returns empty array for text without links' do
      extractor = described_class.new('No links here')
      expect(extractor.links).to be_empty
    end
  end
  
  describe '#tags' do
    it 'extracts hashtags from text' do
      expect(extractor.tags).to eq(sample_tags)
    end
    
    it 'handles multiple hashtags' do
      extractor = described_class.new('Check out #ruby #rails #programming')
      expect(extractor.tags).to contain_exactly('ruby', 'rails', 'programming')
    end
  end
  
  describe '#link_objects' do
    context 'without OpenGraph' do
      it 'returns basic link information' do
        result = extractor.link_objects
        expect(result.first[:url]).to eq('https://example.com')
        expect(result.first[:opengraph]).to be_nil
      end
    end
    
    context 'with OpenGraph' do
      before do
        allow(og_service).to receive(:extract).and_return({ title: 'Example Site' })
      end
      
      it 'includes OpenGraph metadata' do
        result = extractor.link_objects(with_opengraph: true)
        expect(result.first[:opengraph][:title]).to eq('Example Site')
      end
    end
  end
end
```

## 🏁 Summary

- Keep tests focused, descriptive, and DRY.
- Use shared contexts and verifying doubles.
- Reference this page for all test suite questions.
- All documentation, README, and contributing guides point here for test details.

## Test & Quality Status (June 2025)

- **RSpec:** 35 examples, 0 failures
- **RuboCop:** No offenses detected
- **YARD:** 85.86% documented, a few dynamic mixin warnings (expected for Rails mixins)
- **Gem build:** No gemspec self-inclusion error (fixed June 2025)

---

**RichTextExtraction** – Professional rich text extraction for Ruby and Rails applications. 🚀 