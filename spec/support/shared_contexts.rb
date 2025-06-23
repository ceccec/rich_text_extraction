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
