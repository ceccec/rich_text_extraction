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
require_relative '../../lib/rich_text_extraction/helpers'
require_relative '../../lib/rich_text_extraction/extracts_rich_text'

# Dummy classes for test stubs
class DummyJob
  def self.perform(url)
    RichTextExtraction::Extractor.new(url).link_objects(with_opengraph: true)
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
      include RichTextExtraction::ExtractionHelpers
      public(*RichTextExtraction::InstanceHelpers.instance_methods(false))
      public(*RichTextExtraction::ExtractionHelpers.instance_methods(false))
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
      include RichTextExtraction::ExtractsRichText

      def initialize(dummy_body)
        @dummy_body_class = dummy_body
      end

      def body
        @body ||= @dummy_body_class.new('https://example.com')
      end
    end
  end
end

RSpec.shared_context 'with Rails stubs' do
  let(:rails_stub) do
    stub_const('Rails', Class.new)
    Rails.singleton_class.class_eval do
      attr_accessor :cache, :application
    end
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    Rails.application = instance_double('App', class: instance_double('AppClass', module_parent_name: 'TestApp'))
  end
end

RSpec.shared_context 'with HTTParty stubs' do
  let(:successful_response) do
    instance_double('Response', success?: true, body: '<meta property="og:title" content="Title">')
  end

  let(:failed_response) do
    instance_double('Response', success?: false, body: '')
  end
end

# Commonly used test objects
RSpec.shared_context 'with test helper' do
  let(:helper) { Class.new { include RichTextExtraction::Helpers }.new }
end

RSpec.shared_context 'with test OpenGraph data' do
  let(:og) { { 'title' => 'Test', 'url' => 'https://test.com' } }
end

RSpec.shared_context 'with test extractor' do
  let(:extractor) { RichTextExtraction::Extractor.new('https://example.com') }
end

RSpec.shared_context 'with test cache' do
  let(:cache) { {} }
end

RSpec.shared_context 'with error extractor' do
  let(:extractor) { RichTextExtraction::Extractor.new('https://badurl.com') }
end

# Shared examples for common test patterns
RSpec.shared_examples 'extracts links from text' do
  it 'extracts all links' do
    expect(subject.links).to include('https://example.com', 'http://test.com')
  end
end

RSpec.shared_examples 'extracts tags from text' do
  it 'extracts tags' do
    expect(subject.tags).to include('welcome')
  end
end

RSpec.shared_examples 'extracts mentions from text' do
  it 'extracts mentions' do
    expect(subject.mentions).to include('alice')
  end
end

RSpec.shared_examples 'renders OpenGraph preview' do
  it 'includes the title' do
    expect(result).to include('Test')
  end

  it 'includes the url' do
    expect(result).to include('https://test.com')
  end
end

RSpec.shared_examples 'handles OpenGraph errors' do
  it 'returns an error in the opengraph hash' do
    expect(result).to have_key(:error)
  end
end

RSpec.shared_examples 'sanitizes HTML' do
  it 'removes script tags' do
    expect(result).not_to include('<script>')
  end
end
