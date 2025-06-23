# frozen_string_literal: true

##
# Tests for OpenGraph extraction and preview helpers in RichTextExtraction
#
# Covers OpenGraph extraction, preview rendering, and error handling.

require 'spec_helper'
require 'rich_text_extraction'
require 'active_support'
require 'active_support/cache'
require_relative 'support/shared_contexts'

RSpec.describe RichTextExtraction::OpenGraphHelpers do
  include_context 'with test cache'
  include_context 'with test extractor'

  context 'when using custom cache options and key prefix' do
    include_context 'with Rails stubs'

    it 'stores OpenGraph data in the cache' do
      extractor.link_objects(with_opengraph: true, cache: cache, cache_options: { key_prefix: 'custom' })
      expect(cache).not_to be_empty
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

    it 'renders markdown format' do
      result = helper.opengraph_preview_for(og, format: :markdown)
      expect(result).to include('Test')
    end

    it 'renders text format' do
      result = helper.opengraph_preview_for(og, format: :text)
      expect(result).to include('Test')
    end
  end

  context 'when handling errors in OpenGraph extraction' do
    include_context 'with error extractor'

    it 'returns an error in the opengraph hash' do
      result = extractor.link_objects(with_opengraph: true).first[:opengraph]
      expect(result).to have_key(:error)
    end
  end
end
