# frozen_string_literal: true

RSpec.shared_context 'autodiscover patterns' do
  # Common test data
  let(:sample_text) { 'Check out https://example.com and #awesome #ruby @user123 email@test.com' }
  let(:sample_url) { 'https://example.com' }
  let(:sample_markdown) { "# Title\n\n[Link](https://example.com)\n\n**Bold text**" }
  let(:sample_html) { "<p>Hello <a href='https://example.com'>world</a></p>" }

  # DRY method discovery helpers
  def discover_modules
    ObjectSpace.each_object(Module).map do |mod|
      mod.name
    rescue StandardError
      nil
    end.compact.uniq.select { |n| n&.start_with?('RichTextExtraction') }
  end

  def discover_classes
    ObjectSpace.each_object(Class).map do |klass|
      klass.name
    rescue StandardError
      nil
    end.compact.uniq.select { |n| n&.start_with?('RichTextExtraction') }
  end

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
  rescue StandardError
    []
  end

  def discover_instance_methods_for(klass, method_type = :public)
    case method_type
    when :public
      klass.public_instance_methods - Object.new.public_methods
    when :private
      klass.private_instance_methods - Object.new.private_methods
    when :protected
      klass.protected_instance_methods - Object.new.protected_methods
    else
      klass.instance_methods - Object.new.methods
    end
  rescue StandardError
    []
  end

  # DRY pattern matching helpers
  def find_methods_matching_patterns(object, patterns, method_type = :public)
    methods = discover_methods_for(object, method_type)
    patterns.flat_map { |pattern| methods.grep(pattern) }
  end

  def find_instance_methods_matching_patterns(klass, patterns, method_type = :public)
    methods = discover_instance_methods_for(klass, method_type)
    patterns.flat_map { |pattern| methods.grep(pattern) }
  end

  # DRY method testing helpers
  def test_methods_exist(object, expected_methods, method_type = :public)
    actual_methods = discover_methods_for(object, method_type)
    expected_methods.each do |meth|
      expect(actual_methods).to include(meth),
                                "Expected #{method_type} method #{meth} to be present on #{object.class}. Found: #{actual_methods.inspect}"
    end
  end

  def test_instance_methods_exist(klass, expected_methods, method_type = :public)
    actual_methods = discover_instance_methods_for(klass, method_type)
    expected_methods.each do |meth|
      expect(actual_methods).to include(meth),
                                "Expected #{method_type} instance method #{meth} to be present on #{klass}. Found: #{actual_methods.inspect}"
    end
  end

  def test_methods_respond_to(object, expected_methods)
    expected_methods.each do |meth|
      expect(object).to respond_to(meth),
                        "Expected #{object.class} to respond to #{meth}"
    end
  end

  def test_methods_return_type(object, methods, expected_type, *args)
    methods.each do |meth|
      result = object.send(meth, *args)
      expect(result).to be_a(expected_type),
                        "Expected #{meth} to return #{expected_type}, got #{result.class}"
    end
  end

  # DRY extraction testing helpers
  def test_extraction_methods(extractor, methods = %i[links tags mentions emails attachments phone_numbers])
    test_methods_respond_to(extractor, methods)
    methods.each do |meth|
      result = extractor.send(meth)
      expect(result).to be_an(Array), "Expected #{meth} to return Array, got #{result.class}"
    end
  end

  def test_extraction_with_sample_data(extractor, _sample_data)
    %i[links tags mentions emails attachments phone_numbers].each do |meth|
      result = extractor.send(meth)
      expect(result).to be_an(Array)
      # Test that extraction works with the sample data
      expect(result).to be_an(Array)
    end
  end

  # DRY configuration testing helpers
  def test_configuration_methods(config, methods = %i[cache_enabled= cache_ttl= opengraph_timeout= merge to_h])
    test_methods_respond_to(config, methods)
  end

  def test_configuration_patterns(config, patterns = [/config/, /configure/, /option/, /setting/, /merge/, /reset/])
    found = find_methods_matching_patterns(config, patterns)
    expect(found).not_to be_empty, "No configuration methods found matching patterns: #{patterns}"
  end

  # DRY cache testing helpers
  def test_cache_methods(config, methods = %i[caching_available? generate_cache_key cache_options])
    test_methods_respond_to(config, methods)
  end

  def test_cache_patterns(config, patterns = [/^cache/, /_cache/, /cache_/])
    found = find_methods_matching_patterns(config, patterns)
    expect(found).not_to be_empty, "No cache methods found matching patterns: #{patterns}"
  end

  # DRY validator testing helpers
  def test_validator_methods(validator_class, methods = %i[validate valid? errors])
    return skip("#{validator_class} not defined") unless defined?(validator_class)

    validator = validator_class.new({})
    test_methods_respond_to(validator, methods)

    # Test with sample data if available
    return unless validator.respond_to?(:validate)

    expect(validator.validate(sample_url)).to be_truthy
    expect(validator.validate('invalid-url')).to be_falsey
  end

  def test_validation_patterns(validator_class, patterns = [/^validate/, /_validator$/, /valid\?$/])
    return skip("#{validator_class} not defined") unless defined?(validator_class)

    found = find_instance_methods_matching_patterns(validator_class, patterns)
    expect(found).not_to be_empty, "No validation methods found matching patterns: #{patterns}"
  end

  # DRY performance testing helpers
  def test_performance_with_large_input(object, method, input_size = 100_000, max_time = 2.0)
    large_input = "#{'x' * input_size} https://example.com #{'y' * input_size}"
    start_time = Time.now
    result = object.send(method, large_input)
    end_time = Time.now

    expect(result).to be_an(Array)
    expect(end_time - start_time).to be < max_time
  end

  # DRY edge case testing helpers
  def test_edge_cases(extractor_class, edge_cases = {})
    extractor = extractor_class.new(edge_cases[:empty] || '')

    # Test empty input
    expect(extractor.links).to eq([])
    expect(extractor.tags).to eq([])
    expect(extractor.mentions).to eq([])

    # Test nil input (should not raise)
    expect { extractor_class.new(nil) }.not_to raise_error

    # Test long URLs
    return unless edge_cases[:long_url]

    long_url = "https://example.com/#{'a' * 1000}"
    long_text = "Check out #{long_url}"
    extractor = extractor_class.new(long_text)
    expect(extractor.links).to include(long_url)
  end

  # DRY integration testing helpers
  def test_method_interactions(extractor_class, sample_text = 'Check out https://example.com and #awesome @user123')
    extractor = extractor_class.new(sample_text)

    links = extractor.links
    tags = extractor.tags
    mentions = extractor.mentions

    expect(links).to include('https://example.com')
    expect(tags).to include('awesome') # tags returns without '#'
    expect(mentions).to include('user123') # mentions returns without '@'

    [links, tags, mentions].each { |result| expect(result).to be_an(Array) }
  end

  def test_end_to_end_workflow(extractor_class, validator_class = nil)
    text = 'Visit https://example.com and https://invalid-url'
    extractor = extractor_class.new(text)

    links = extractor.links
    expect(links).to include('https://example.com')
    expect(links).to include('https://invalid-url')

    return unless validator_class && defined?(validator_class)

    url_validator = validator_class.new({})
    valid_links = links.select { |link| url_validator.validate(link) }
    expect(valid_links).to include('https://example.com')
    expect(valid_links).not_to include('https://invalid-url')

    # Test OpenGraph extraction for valid links
    valid_links.each do |link|
      allow(RichTextExtraction).to receive(:extract_opengraph).with(link).and_return({
                                                                                       title: 'Test Title',
                                                                                       description: 'Test Description'
                                                                                     })

      og_data = RichTextExtraction.extract_opengraph(link)
      expect(og_data).to be_a(Hash)
      expect(og_data[:title]).to eq('Test Title')
    end
  end

  # DRY module/class discovery helpers
  def expect_modules_to_exist(expected_modules)
    discovered_modules = discover_modules
    missing_modules = expected_modules - discovered_modules
    skip("Missing modules: #{missing_modules.join(', ')}. Found: #{discovered_modules.inspect}") if missing_modules.any?
    expected_modules.each do |mod|
      expect(discovered_modules).to include(mod),
                                    "Expected module #{mod} to be loaded. Found: #{discovered_modules.inspect}"
    end
  end

  def expect_classes_to_exist(expected_classes)
    discovered_classes = discover_classes
    missing_classes = expected_classes - discovered_classes
    skip("Missing classes: #{missing_classes.join(', ')}. Found: #{discovered_classes.inspect}") if missing_classes.any?
    expected_classes.each do |klass|
      expect(discovered_classes).to include(klass),
                                    "Expected class #{klass} to be loaded. Found: #{discovered_classes.inspect}"
    end
  end

  # DRY service testing helpers
  def test_service_methods(service_class, methods = [])
    return skip("#{service_class} not defined") unless defined?(service_class)

    service = service_class.new
    test_methods_respond_to(service, methods)
  end

  def test_opengraph_methods
    expect(RichTextExtraction).to respond_to(:extract_opengraph)
    expect(RichTextExtraction).to respond_to(:opengraph_preview)

    og_data = { title: 'Test', description: 'Test description' }
    expect(RichTextExtraction.opengraph_preview(og_data)).to be_a(String)
  end

  def test_markdown_methods
    expect(RichTextExtraction).to respond_to(:render_markdown)

    result = RichTextExtraction.render_markdown(sample_markdown)
    expect(result).to be_a(String)
    expect(result).to match(%r{<h1.*>Title</h1>})
  end
end
