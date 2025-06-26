# frozen_string_literal: true

##
# Comprehensive tests for OpenGraph functionality in RichTextExtraction
#
# This file consolidates all OpenGraph-related tests to eliminate duplication
# and provide a single source of truth for OpenGraph functionality.

require 'spec_helper'
require 'rich_text_extraction/services/opengraph_service'

RSpec.describe 'OpenGraph Functionality' do
  describe 'Basic OpenGraph extraction' do
    include_context 'with OpenGraph setup'

    it 'provides OpenGraph extraction functionality' do
      expect(extractor).to respond_to(:link_objects)
    end

    it 'supports caching options' do
      expect(extractor.link_objects(with_opengraph: true, cache: cache)).to be_an(Array)
    end

    include_examples 'handles OpenGraph extraction'
  end

  describe 'OpenGraph preview rendering' do
    include_context 'with OpenGraph setup'

    context 'HTML format' do
      include_examples 'renders OpenGraph previews', :html
    end

    context 'Markdown format' do
      include_examples 'renders OpenGraph previews', :markdown
    end

    context 'Text format' do
      include_examples 'renders OpenGraph previews', :text
    end
  end

  describe 'OpenGraph caching' do
    include_context 'with OpenGraph setup'

    include_examples 'handles OpenGraph caching'
    include_examples 'handles caching correctly'
  end

  describe 'OpenGraph error handling' do
    include_context 'with error setup'

    include_examples 'handles errors gracefully'
  end

  describe 'Advanced OpenGraph features' do
    include_context 'with OpenGraph setup'

    it 'handles OpenGraph data with images' do
      result = helper.opengraph_preview_for(og_with_image)
      expect(result).to include('image.jpg')
    end

    it 'handles OpenGraph data with site names' do
      result = helper.opengraph_preview_for(og_with_site_name)
      expect(result).to include('Test Site')
    end

    it 'handles missing OpenGraph properties gracefully' do
      incomplete_og = { 'title' => 'Test' }
      result = helper.opengraph_preview_for(incomplete_og)
      expect(result).to include('Test')
    end
  end

  describe 'Performance with OpenGraph' do
    include_context 'with performance test data'
    include_context 'with OpenGraph setup'

    it 'handles large amounts of OpenGraph data efficiently' do
      performance = measure_performance do
        extractor.link_objects(with_opengraph: true, cache: cache)
      end
      expect(performance[:duration]).to be < 2.0
    end
  end
end

RSpec.describe RichTextExtraction::OpenGraphService do
  let(:service) { described_class.new }

  it 'returns error for invalid URL' do
    result = service.extract('not_a_url')
    expect(result).to have_key(:error)
  end

  it 'fetches OpenGraph data (stubbed)' do
    allow(HTTParty).to receive(:get).and_return(double(success?: true,
                                                       body: '<meta property="og:title" content="Test">'))
    result = service.extract('https://example.com', cache: nil)
    expect(result['title']).to eq('Test')
  end
end
