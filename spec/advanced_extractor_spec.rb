# frozen_string_literal: true

##
# Advanced extractor tests for RichTextExtraction
#
# Tests using the Extractor directly outside Rails.

require 'spec_helper'
require_relative 'support/shared_contexts'

RSpec.describe 'Advanced extractor usage' do
  include_context 'with HTTParty stubs'

  context 'when using the Extractor directly outside Rails' do
    let(:extractor) { RichTextExtraction::Extractor.new('https://example.com') }

    it 'returns the correct url' do
      allow(HTTParty).to receive(:get).and_return(successful_response)
      result = extractor.link_objects(with_opengraph: true)
      expect(result.first[:url]).to eq('https://example.com')
    end

    it 'returns the correct OpenGraph title' do
      allow(HTTParty).to receive(:get).and_return(successful_response)
      result = extractor.link_objects(with_opengraph: true)
      expect(result.first[:opengraph]['title']).to eq('Title')
    end
  end
end 