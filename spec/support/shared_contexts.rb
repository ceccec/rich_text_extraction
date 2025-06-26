# frozen_string_literal: true

##
# Shared contexts and test helpers for RichTextExtraction tests
#
# This file contains reusable test setup code that can be included
# across multiple test files to avoid duplication and improve maintainability.

require 'spec_helper'
require 'rich_text_extraction'
require 'active_support'
require 'active_support/cache'
require_relative '../../lib/rich_text_extraction/helpers/helpers_module'
require_relative '../../lib/rich_text_extraction/rails/extracts_rich_text'

# =============================================================================
# COMMON TEST DATA
# =============================================================================

RSpec.shared_context 'with common test data' do
  let(:sample_text) { 'Check out #welcome and @alice at https://example.com' }
  let(:sample_url) { 'https://example.com' }
  let(:sample_html) do
    '<meta property="og:title" content="Test Title"><meta property="og:description" content="Test Description">'
  end

  let(:test_tags) { ['welcome'] }
  let(:test_mentions) { ['alice'] }
  let(:test_links) { ['https://example.com'] }
end

# =============================================================================
# DUMMY CLASSES
# =============================================================================

# Dummy classes for test stubs
class DummyJob
  def self.perform(url)
    RichTextExtraction::Extractors::Extractor.new(url).link_objects(with_opengraph: true)
  end
end

class ActionTextJob
  def self.perform(body)
    body.link_objects(with_opengraph: true)
  end
end

RSpec.shared_context 'when using a dummy body class' do
  let(:dummy_body_class) do
    Class.new do
      include RichTextExtraction
      include RichTextExtraction::Extractors::ExtractionHelpers
      public(*RichTextExtraction::Helpers::InstanceHelpers.instance_methods(false))
      public(*RichTextExtraction::Extractors::ExtractionHelpers.instance_methods(false))
      public :opengraph_key_prefix

      def initialize(text)
        @text = text
      end

      def to_plain_text
        @text
      end
    end
  end
end

RSpec.shared_context 'when using a dummy class' do
  let(:dummy_class) do
    Class.new do
      include RichTextExtraction::Rails::ExtractsRichText

      def initialize(dummy_body)
        @dummy_body_class = dummy_body
      end

      def body
        @body ||= @dummy_body_class.new('https://example.com')
      end
    end
  end
end

# =============================================================================
# RAILS STUBS
# =============================================================================

RSpec.shared_context 'with Rails stubs' do
  before do
    # Stub Rails module if not already defined
    stub_const('Rails', Class.new) unless defined?(Rails)

    # Configure Rails singleton methods
    Rails.singleton_class.class_eval do
      attr_accessor :cache, :application
    end

    # Set up Rails cache - create fresh instance for each test
    Rails.cache = ActiveSupport::Cache::MemoryStore.new

    # Set up Rails application with routes
    app_double = instance_double('App', class: instance_double('AppClass', module_parent_name: 'TestApp'))
    routes_double = instance_double('Routes')
    Rails.application = app_double
    allow(Rails.application).to receive(:routes).and_return(routes_double)
  end

  after do
    # Clean up to prevent leaks
    Rails.cache = nil
    Rails.application = nil
  end
end

# =============================================================================
# HTTP STUBS
# =============================================================================

RSpec.shared_context 'with HTTParty stubs' do
  let(:successful_response) do
    instance_double('Response', success?: true, body: sample_html)
  end

  let(:failed_response) do
    instance_double('Response', success?: false, body: '')
  end

  let(:timeout_response) do
    instance_double('Response', success?: false, body: '', code: 408)
  end

  let(:server_error_response) do
    instance_double('Response', success?: false, body: '', code: 500)
  end
end

RSpec.shared_context 'with HTTParty success stub' do
  include_context 'with HTTParty stubs'

  before do
    allow(HTTParty).to receive(:get).and_return(successful_response)
  end
end

RSpec.shared_context 'with HTTParty failure stub' do
  include_context 'with HTTParty stubs'

  before do
    allow(HTTParty).to receive(:get).and_return(failed_response)
  end
end

RSpec.shared_context 'with HTTParty timeout stub' do
  include_context 'with HTTParty stubs'

  before do
    allow(HTTParty).to receive(:get).and_return(timeout_response)
  end
end

# =============================================================================
# TEST OBJECTS
# =============================================================================

RSpec.shared_context 'with test helper' do
  let(:helper) { Class.new { include RichTextExtraction::Helpers::HelpersModule }.new }
end

RSpec.shared_context 'with test OpenGraph data' do
  let(:og) { { 'title' => 'Test', 'url' => 'https://test.com', 'description' => 'Test Description' } }
  let(:og_with_image) { og.merge('image' => 'https://test.com/image.jpg') }
  let(:og_with_site_name) { og.merge('site_name' => 'Test Site') }
end

RSpec.shared_context 'with test extractor' do
  let(:extractor) { RichTextExtraction::Extractors::Extractor.new(sample_text) }
end

RSpec.shared_context 'with test cache' do
  let(:cache) { {} }
  let(:memory_cache) { ActiveSupport::Cache::MemoryStore.new }
  let(:redis_cache) { instance_double('Redis') }
end

RSpec.shared_context 'with error extractor' do
  let(:extractor) { RichTextExtraction::Extractors::Extractor.new('https://badurl.com') }
end

RSpec.shared_context 'with markdown test data' do
  let(:markdown_text) { '**Bold** *Italic* [Link](https://example.com)' }
  let(:markdown_with_code) { '`code` and ```block code```' }
  let(:markdown_with_list) { "- Item 1\n- Item 2\n- Item 3" }
end

# =============================================================================
# VALIDATOR TEST DATA
# =============================================================================

RSpec.shared_context 'with validator test data' do
  let(:valid_urls) { ['https://example.com', 'http://test.com', 'https://sub.domain.co.uk'] }
  let(:invalid_urls) { ['not-a-url', 'ftp://example.com', 'javascript:alert(1)'] }

  let(:valid_emails) { ['test@example.com', 'user.name@domain.co.uk'] }
  let(:invalid_emails) { ['not-an-email', 'test@', '@domain.com'] }

  let(:valid_hashtags) { ['#test', '#hashtag', '#123'] }
  let(:invalid_hashtags) { ['not-a-hashtag', '#', '#a'] }

  let(:valid_mentions) { ['@user', '@test_user', '@123'] }
  let(:invalid_mentions) { ['not-a-mention', '@', '@a'] }
end

# =============================================================================
# PERFORMANCE TEST DATA
# =============================================================================

RSpec.shared_context 'with performance test data' do
  let(:large_text) { sample_text * 1000 }
  let(:many_urls) { Array.new(100) { |i| "https://example#{i}.com" }.join(' ') }
  let(:many_tags) { Array.new(50) { |i| "#tag#{i}" }.join(' ') }
end

# =============================================================================
# COMMON SETUP PATTERNS
# =============================================================================

RSpec.shared_context 'with common setup' do
  include_context 'with common test data'
  include_context 'with test cache'
  include_context 'with test extractor'
  include_context 'with test helper'
end

RSpec.shared_context 'with OpenGraph setup' do
  include_context 'with common test data'
  include_context 'with test OpenGraph data'
  include_context 'with test cache'
  include_context 'with test extractor'
  include_context 'with test helper'
  include_context 'with HTTParty success stub'
end

RSpec.shared_context 'with error setup' do
  include_context 'with common test data'
  include_context 'with test cache'
  include_context 'with error extractor'
  include_context 'with HTTParty failure stub'
end

RSpec.shared_context 'with Rails integration setup' do
  include_context 'with Rails stubs'
  include_context 'with common test data'
  include_context 'with test cache'
  include_context 'with test extractor'
end

# =============================================================================
# DUMMY CLASSES FOR TESTING
# =============================================================================

RSpec.shared_context 'with dummy body class' do
  let(:dummy_body_class) do
    Class.new do
      include RichTextExtraction
      include RichTextExtraction::Extractors::ExtractionHelpers
      public(*RichTextExtraction::Helpers::InstanceHelpers.instance_methods(false))
      public(*RichTextExtraction::Extractors::ExtractionHelpers.instance_methods(false))
      public :opengraph_key_prefix

      def initialize(text)
        @text = text
      end

      def to_plain_text
        @text
      end

      # Explicitly define link_objects as a public instance method
      def link_objects(with_opengraph: false, cache: nil, cache_options: {})
        extractor = RichTextExtraction::Extractors::Extractor.new(@text)
        extractor.link_objects(with_opengraph: with_opengraph, cache: cache, cache_options: cache_options)
      end
    end
  end

  let(:dummy_body) { dummy_body_class.new(sample_text) }
end

RSpec.shared_context 'with dummy instance' do
  include_context 'with dummy body class'

  let(:dummy_instance) do
    Class.new do
      include RichTextExtraction
      include RichTextExtraction::Extractors::ExtractionHelpers

      def initialize(dummy_body)
        @dummy_body_class = dummy_body
      end

      def body
        @body ||= @dummy_body_class.new('https://example.com')
      end
    end.new(dummy_body_class)
  end
end

# =============================================================================
# HELPER METHODS
# =============================================================================

module TestHelpers
  def create_test_extractor(url = sample_url)
    RichTextExtraction::Extractors::Extractor.new(url)
  end

  def create_test_cache
    ActiveSupport::Cache::MemoryStore.new
  end

  def create_test_helper
    Class.new { include RichTextExtraction::Helpers::HelpersModule }.new
  end

  def stub_httparty_success(html = sample_html)
    allow(HTTParty).to receive(:get).and_return(
      instance_double('Response', success?: true, body: html)
    )
  end

  def stub_httparty_failure
    allow(HTTParty).to receive(:get).and_return(
      instance_double('Response', success?: false, body: '')
    )
  end

  def measure_performance
    start_time = Time.now
    result = yield
    end_time = Time.now
    { result: result, duration: end_time - start_time }
  end
end

RSpec.configure do |config|
  config.include TestHelpers
end

# Add missing variables that are referenced in specs
RSpec.shared_context 'with missing variables' do
  let(:successful_response) do
    instance_double('Response', success?: true, body: sample_html)
  end

  let(:failed_response) do
    instance_double('Response', success?: false, body: '')
  end

  let(:dummy_body_class) do
    Class.new do
      include RichTextExtraction
      include RichTextExtraction::Extractors::ExtractionHelpers

      def initialize(text)
        @text = text
      end

      def to_plain_text
        @text
      end

      # Explicitly define link_objects as a public instance method
      def link_objects(with_opengraph: false, cache: nil, cache_options: {})
        extractor = RichTextExtraction::Extractors::Extractor.new(@text)
        extractor.link_objects(with_opengraph: with_opengraph, cache: cache, cache_options: cache_options)
      end
    end
  end
end
