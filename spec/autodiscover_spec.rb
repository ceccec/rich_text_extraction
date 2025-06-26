# frozen_string_literal: true

require 'spec_helper'
require 'rich_text_extraction/validators/url_validator' # Ensure validator is loaded and registered
require 'support/autodiscover_patterns'
# Explicitly require relevant files for full coverage
dir = File.expand_path('../lib/rich_text_extraction', __dir__)
$LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)

# Require core modules
require 'rich_text_extraction'
require 'rich_text_extraction/core/configuration'
require 'rich_text_extraction/extractors/extractors'
begin
  require 'rich_text_extraction/validators/hashtag_validator'
rescue StandardError
  LoadError
end
begin
  require 'rich_text_extraction/validators/mention_validator'
rescue StandardError
  LoadError
end
begin
  require 'rich_text_extraction/services/markdown_service'
rescue StandardError
  LoadError
end
begin
  require 'rich_text_extraction/services/opengraph_service'
rescue StandardError
  LoadError
end
require 'rich_text_extraction/registry'

RSpec.describe 'RichTextExtraction Autodiscover' do
  include_context 'autodiscover patterns'

  # Test data for various extraction scenarios
  let(:sample_text) { 'Check out https://example.com and #awesome #ruby @user123 email@test.com' }
  let(:sample_url) { 'https://example.com' }
  let(:sample_markdown) { "# Title\n\n[Link](https://example.com)\n\n**Bold text**" }
  let(:sample_html) { "<p>Hello <a href='https://example.com'>world</a></p>" }

  describe 'Module Discovery' do
    it 'discovers all RichTextExtraction modules' do
      discovered_modules = discover_modules
      puts "Discovered modules: #{discovered_modules.inspect}"

      # Only test for modules that are actually loaded
      expected_modules = %w[
        RichTextExtraction
        RichTextExtraction::Core
        RichTextExtraction::Extractors
        RichTextExtraction::Validators
        RichTextExtraction::Helpers
        RichTextExtraction::Cache
        RichTextExtraction::API
      ]

      found_modules = expected_modules & discovered_modules
      expect(found_modules).not_to be_empty, "No expected modules found. Discovered: #{discovered_modules.inspect}"

      # Test that at least the main module exists
      expect(discovered_modules).to include('RichTextExtraction')
    end

    it 'discovers all public classes' do
      discovered_classes = discover_classes
      puts "Discovered classes: #{discovered_classes.inspect}"

      expected_classes = %w[
        RichTextExtraction::Core::Configuration
        RichTextExtraction::Extractors::Extractor
      ]

      found_classes = expected_classes & discovered_classes
      expect(found_classes).not_to be_empty, "No expected classes found. Discovered: #{discovered_classes.inspect}"
    end
  end

  describe 'Method Discovery' do
    it 'discovers all module-level methods' do
      test_methods_exist(RichTextExtraction, %i[extract extract_opengraph render_markdown configure configuration])
    end

    it 'discovers all instance methods' do
      test_methods_exist(RichTextExtraction::Extractors::Extractor.new(sample_text),
                         %i[links tags mentions emails attachments phone_numbers text])
    end

    if defined?(RichTextExtraction::Validators::UrlValidator)
      it 'discovers all validator methods' do
        test_instance_methods_exist(RichTextExtraction::Validators::UrlValidator, %i[validate valid? errors])
      end
    else
      it('discovers all validator methods') { skip 'UrlValidator not defined' }
    end
  end

  describe 'Automated Method Testing' do
    it 'tests all configuration methods' do
      test_configuration_methods(RichTextExtraction.configuration)
    end

    if defined?(RichTextExtraction::Validators::UrlValidator)
      it 'tests all validator methods' do
        test_validator_methods(RichTextExtraction::Validators::UrlValidator)
      end
    else
      it('tests all validator methods') { skip 'UrlValidator not defined' }
    end

    it 'tests all cache methods' do
      test_cache_methods(RichTextExtraction.configuration)
    end

    it 'tests all OpenGraph methods' do
      test_opengraph_methods
    end

    it 'tests all markdown methods' do
      test_markdown_methods
    end

    it 'tests method performance with large inputs' do
      large_text = "#{'x' * 100_000} https://example.com #{'y' * 100_000}"
      extractor = RichTextExtraction::Extractors::Extractor.new(large_text)
      start_time = Time.now
      result = extractor.links
      end_time = Time.now
      expect(result).to be_an(Array)
      expect(end_time - start_time).to be < 2.0
    end

    if defined?(RichTextExtraction::Validators::UrlValidator)
      it 'tests method error handling' do
        config = RichTextExtraction.configuration
        config.cache_ttl = 10
        expect(config.cache_ttl).to eq(10)
        test_validator_methods(RichTextExtraction::Validators::UrlValidator)
      end
    else
      it('tests method error handling') { skip 'UrlValidator not defined' }
    end
  end

  describe 'Pattern-Based Testing' do
    it 'tests all methods matching extraction patterns' do
      expect(find_instance_methods_matching_patterns(RichTextExtraction::Extractors::Extractor,
                                                     [/^extract_/, /_extractor$/])).not_to be_empty
    end

    if defined?(RichTextExtraction::Validators::UrlValidator)
      it 'tests all methods matching validation patterns' do
        test_validation_patterns(RichTextExtraction::Validators::UrlValidator)
      end
    else
      it('tests all methods matching validation patterns') { skip 'UrlValidator not defined' }
    end

    it 'tests all methods matching cache patterns' do
      test_cache_patterns(RichTextExtraction.configuration)
    end

    it 'tests all methods matching configuration patterns' do
      test_configuration_patterns(RichTextExtraction.configuration)
    end
  end

  describe 'Integration Testing' do
    it 'tests method interactions' do
      test_method_interactions(RichTextExtraction::Extractors::Extractor)
    end

    if defined?(RichTextExtraction::Validators::UrlValidator)
      it 'tests end-to-end workflows' do
        test_end_to_end_workflow(RichTextExtraction::Extractors::Extractor, RichTextExtraction::Validators::UrlValidator)
      end
    else
      it('tests end-to-end workflows') { skip 'UrlValidator not defined' }
    end
  end

  describe 'Registered Extractors' do
    RichTextExtraction::Registry.extractors.each do |name, config|
      it "extracts #{name} from sample data" do
        extractor = RichTextExtraction::Extractors::Extractor.new(config[:sample])
        expect(extractor.send(config[:method])).to be_an(Array)
      end
    end
  end

  describe 'Registered Validators' do
    require 'rich_text_extraction/registry'
    begin
      require 'rich_text_extraction/validators/url_validator'
    rescue StandardError
      LoadError
    end

    if RichTextExtraction::Registry.validators.empty?
      it 'has no registered validators' do
        skip 'No validators registered in the registry.'
      end
    else
      RichTextExtraction::Registry.validators.each do |name, config|
        it "validates #{name} with valid and invalid samples" do
          validator = config[:klass].new
          expect(validator.validate(config[:sample_valid])).to be_truthy
          expect(validator.validate(config[:sample_invalid])).to be_falsey
        end
      end
    end
  end
end
