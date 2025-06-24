# frozen_string_literal: true

##
# Rails integration tests for RichTextExtraction
#
# Tests Rails-specific functionality including caching, view helpers, and Rails integration.

require 'spec_helper'
require 'rich_text_extraction'
require 'active_support'
require 'active_support/cache'
require_relative 'support/shared_contexts'

RSpec.describe 'Rails integration' do
  context 'when clearing cache for links in the body via the concern' do
    include_context 'when using a dummy body class'
    include_context 'when using a dummy class'
    include_context 'with Rails stubs'

    it 'removes the cache entry' do
      rails_stub
      dummy_instance = dummy_class.new(dummy_body_class)
      expect { dummy_instance.clear_rich_text_link_cache }.not_to raise_error
    end
  end

  context 'when rendering opengraph preview in the view helper' do
    include_context 'with test helper'
    include_context 'with test OpenGraph data'

    it 'includes the title' do
      result = helper.opengraph_preview_for(og)
      expect(result).to include('Test')
    end

    it 'includes the url' do
      result = helper.opengraph_preview_for(og)
      expect(result).to include('https://test.com')
    end
  end
end
