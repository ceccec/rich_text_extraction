# frozen_string_literal: true

##
# Advanced cache usage tests for RichTextExtraction
#
# Tests custom cache options, key prefixes, and cache integration.

require 'spec_helper'
require_relative 'support/shared_contexts'

RSpec.describe 'Advanced cache usage' do
  include_context 'with HTTParty stubs'

  context 'when using custom cache options and key prefix' do
    let(:cache) { {} }
    let(:extractor) { RichTextExtraction::Extractor.new('https://example.com') }

    it 'stores OpenGraph data in the cache' do
      allow(HTTParty).to receive(:get).and_return(successful_response)
      extractor.link_objects(with_opengraph: true, cache: cache, cache_options: { key_prefix: 'custom' })
      expect(cache['https://example.com']).to be_a(Hash)
    end
  end
end
