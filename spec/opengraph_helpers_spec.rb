# frozen_string_literal: true

##
# Tests for OpenGraph extraction and preview helpers in RichTextExtraction
#
# Covers OpenGraph extraction, preview rendering, and error handling.

require 'spec_helper'
require_relative 'support/shared_contexts'

RSpec.describe 'OpenGraph helpers' do
  include_context 'with HTTParty stubs'
  include_context 'with Rails stubs'

  context 'when using custom cache options and key prefix' do
    let(:cache) { {} }
    let(:extractor) { RichTextExtraction::Extractor.new('https://example.com') }

    it 'stores OpenGraph data in the cache' do
      allow(HTTParty).to receive(:get).and_return(successful_response)
      extractor.link_objects(with_opengraph: true, cache: cache, cache_options: { key_prefix: 'custom' })
      expect(cache['https://example.com']).to be_a(Hash)
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

    it 'renders markdown format' do
      expect(helper.opengraph_preview_for(og, format: :markdown)).to include('**Test**')
    end

    it 'renders text format' do
      expect(helper.opengraph_preview_for(og, format: :text)).to include('Test')
    end
  end

  context 'when handling errors in OpenGraph extraction' do
    let(:extractor) { RichTextExtraction::Extractor.new('https://badurl.com') }

    it 'returns an error in the opengraph hash' do
      allow(HTTParty).to receive(:get).and_raise(StandardError.new('fail'))
      result = extractor.link_objects(with_opengraph: true)
      expect(result.first[:opengraph][:error]).to eq('fail')
    end
  end
end

RSpec.describe RichTextExtraction::OpenGraphHelpers do
  # Add OpenGraphHelpers tests here
  it 'is a placeholder for OpenGraphHelpers tests' do
    expect(true).to be true
  end
end
