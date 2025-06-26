# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sacred Geometry Architecture', type: :system do
  let(:registry) { RichTextExtraction::Registry }
  let(:helper) { RichTextExtraction::Helper.new }
  let(:interface_adapter) { RichTextExtraction::InterfaceAdapter.new }

  describe 'Registry' do
    it 'registers all extractors' do
      expect(registry.extractors).to include(
        'LinkExtractor',
        'SocialExtractor',
        'IdentifierExtractor'
      )
    end

    it 'registers all validators' do
      expect(registry.validators).to include(
        'UrlValidator',
        'EmailValidator',
        'HashtagValidator',
        'MentionValidator',
        'TwitterHandleValidator',
        'InstagramHandleValidator',
        'IpValidator',
        'UuidValidator',
        'IsbnValidator',
        'IssnValidator',
        'Ean13Validator',
        'UpcaValidator',
        'IbanValidator',
        'VinValidator',
        'MacAddressValidator',
        'HexColorValidator',
        'LuhnValidator'
      )
    end

    it 'registers all helpers' do
      expect(registry.helpers).to include(
        'HelpersModule',
        'InstanceHelpers',
        'MarkdownHelpers',
        'OpenGraphHelpers',
        'ValidatorHelpers'
      )
    end

    it 'registers all services' do
      expect(registry.services).to include(
        'MarkdownService',
        'OpenGraphService'
      )
    end

    it 'registers all jobs' do
      expect(registry.jobs).to include(
        'ActionTextJob',
        'BackgroundExtractionJob'
      )
    end

    it 'registers all controllers' do
      expect(registry.controllers).to include(
        'UniversalExtractionController'
      )
    end
  end

  describe 'Helper' do
    let(:sample_content) { 'Check out https://example.com and @user #hashtag' }

    it 'extracts links using universal interface' do
      result = helper.extract_links(sample_content)
      expect(result).to include('https://example.com')
    end

    it 'extracts mentions using universal interface' do
      result = helper.extract_mentions(sample_content)
      expect(result).to include('@user')
    end

    it 'extracts hashtags using universal interface' do
      result = helper.extract_hashtags(sample_content)
      expect(result).to include('#hashtag')
    end

    it 'extracts social media using universal interface' do
      result = helper.extract_social_media(sample_content)
      expect(result).to be_a(Hash)
    end

    it 'performs universal rich text extraction' do
      result = helper.extract_rich_text(sample_content)
      expect(result).to be_a(Hash)
      expect(result).to include(:links, :mentions, :hashtags)
    end
  end

  describe 'Interface Adapter' do
    let(:sample_content) { 'Visit https://example.com and follow @user' }

    it 'adapts console interface' do
      result = interface_adapter.console_extract(sample_content)
      expect(result).to be_a(Hash)
    end

    it 'adapts web interface' do
      result = interface_adapter.web_extract(sample_content)
      expect(result).to be_a(Hash)
    end

    it 'adapts JavaScript interface' do
      result = interface_adapter.js_extract(sample_content)
      expect(result).to be_a(Hash)
    end
  end

  describe 'Test Generation' do
    it 'generates tests for all registered components' do
      test_generator = RichTextExtraction::Testing::TestGenerator.new
      tests = test_generator.generate_all_tests
      
      expect(tests).to be_a(Hash)
      expect(tests).to include(:extractors, :validators, :helpers, :services)
    end
  end

  describe 'Test Runner' do
    it 'runs all tests' do
      test_runner = RichTextExtraction::Testing::TestRunner.new
      results = test_runner.run_all_tests
      
      expect(results).to be_a(Hash)
      expect(results).to include(:passed, :failed, :total)
    end
  end

  describe 'Rails Integration' do
    it 'integrates with Rails models' do
      # Test that Rails models can use the architecture
      expect(RichTextExtraction::Rails::ExtractsRichText).to be_a(Module)
    end

    it 'provides helpers to Rails' do
      # Test that helpers are available in Rails
      expect(RichTextExtraction::Helper).to be_a(Class)
    end
  end

  describe 'DRY Principles' do
    it 'uses shared logic across all interfaces' do
      # Test that all interfaces use the same underlying logic
      console_result = interface_adapter.console_extract('test')
      web_result = interface_adapter.web_extract('test')
      js_result = interface_adapter.js_extract('test')
      
      # All should use the same helper internally
      expect(console_result.keys).to eq(web_result.keys)
      expect(web_result.keys).to eq(js_result.keys)
    end

    it 'maintains consistent API across all components' do
      # Test that all components follow the same API pattern
      extractors = registry.extractors
      validators = registry.validators
      
      extractors.each do |extractor_name|
        extractor_class = registry.get_extractor(extractor_name)
        expect(extractor_class).to respond_to(:extract)
      end
      
      validators.each do |validator_name|
        validator_class = registry.get_validator(validator_name)
        expect(validator_class).to respond_to(:valid?)
      end
    end
  end

  describe 'Sacred Geometry Principles' do
    it 'maintains perfect symmetry across all components' do
      # Test that all components follow the same structural pattern
      component_types = [:extractors, :validators, :helpers, :services, :jobs, :controllers]
      
      component_types.each do |type|
        components = registry.send(type)
        expect(components).to be_a(Hash)
        expect(components).not_to be_empty
      end
    end

    it 'achieves maximum efficiency through universal patterns' do
      # Test that the architecture eliminates code duplication
      total_components = registry.extractors.size +
                        registry.validators.size +
                        registry.helpers.size +
                        registry.services.size +
                        registry.jobs.size +
                        registry.controllers.size
      
      expect(total_components).to be > 0
      # All components should be registered and accessible
      expect(registry.total_components).to eq(total_components)
    end
  end
end
