# frozen_string_literal: true

##
# Rails integration tests for RichTextExtraction
#
# Tests Rails-specific functionality including caching, view helpers, and Rails integration.

require 'spec_helper'
require_relative 'support/shared_contexts'

RSpec.describe 'Rails integration' do
  include_context 'when using a dummy body class'
  include_context 'when using a dummy class'
  include_context 'with Rails stubs'

  context 'when clearing cache for links in the body via the concern' do
    it 'removes the cache entry' do
      rails_stub
      instance = dummy_class.new(dummy_body_class)
      instance.body.link_objects(with_opengraph: true, cache: :rails)
      expect(Rails.cache.exist?('opengraph:TestApp:https://example.com')).to be true
      instance.clear_rich_text_link_cache
      expect(Rails.cache.exist?('opengraph:TestApp:https://example.com')).to be false
    end
  end

  context 'when rendering opengraph preview in the view helper' do
    let(:helper) { Class.new { include RichTextExtraction::Helpers }.new }
    let(:og) { { 'title' => 'Test', 'url' => 'https://test.com' } }

    it 'includes the title' do
      html = helper.opengraph_preview_for(og)
      expect(html).to include('Test')
    end

    it 'includes the url' do
      html = helper.opengraph_preview_for(og)
      expect(html).to include('https://test.com')
    end
  end
end
