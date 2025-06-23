# frozen_string_literal: true

##
# Advanced extractor tests for RichTextExtraction
#
# Tests using the Extractor directly outside Rails.

require 'spec_helper'
require 'rich_text_extraction'
require 'active_support'
require 'active_support/cache'
require_relative 'support/shared_contexts'

RSpec.describe 'Advanced extractor usage' do
  context 'when using the Extractor directly outside Rails' do
    include_context 'with test extractor'

    it 'returns the correct url' do
      expect(extractor.links.first).to eq('https://example.com')
    end

    it 'returns the correct OpenGraph title' do
      allow(HTTParty).to receive(:get).and_return(double(success?: true, body: '<meta property="og:title" content="Test Title">'))
      result = extractor.link_objects(with_opengraph: true).first
      expect(result[:opengraph]['title']).to eq('Test Title')
    end
  end
end
