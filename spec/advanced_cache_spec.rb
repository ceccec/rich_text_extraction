# frozen_string_literal: true

##
# Advanced cache usage tests for RichTextExtraction
#
# Tests custom cache options, key prefixes, and cache integration.

require 'spec_helper'
require 'rich_text_extraction'
require 'active_support'
require 'active_support/cache'
require_relative 'support/shared_contexts'

RSpec.describe 'Advanced cache usage' do
  context 'when using custom cache options and key prefix' do
    include_context 'with test cache'
    include_context 'with test extractor'

    it 'stores OpenGraph data in the cache' do
      extractor.link_objects(with_opengraph: true, cache: cache, cache_options: { key_prefix: 'custom' })
      expect(cache).not_to be_empty
    end
  end
end
