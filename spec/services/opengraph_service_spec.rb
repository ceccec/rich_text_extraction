# frozen_string_literal: true

# spec/services/opengraph_service_spec.rb
# Tests for RichTextExtraction::OpenGraphService (see lib/rich_text_extraction/services/opengraph_service.rb)

require 'spec_helper'
require 'rich_text_extraction/services/opengraph_service'

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
