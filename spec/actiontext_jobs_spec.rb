# frozen_string_literal: true

##
# ActionText and background job tests for RichTextExtraction
#
# Tests ActionText integration and background job functionality.

require 'spec_helper'
require_relative 'support/shared_contexts'

RSpec.describe 'ActionText and background jobs' do
  include_context 'with HTTParty stubs'

  it 'fetches OpenGraph data for ActionText::RichText' do
    body = RichTextExtraction::Extractor.new('https://example.com')
    allow(HTTParty).to receive(:get).and_return(successful_response)
    expect(body.link_objects(with_opengraph: true).first[:opengraph]['title']).to eq('Title')
  end

  it 'can be used in a background job for ActionText' do
    body = RichTextExtraction::Extractor.new('https://example.com')
    allow(HTTParty).to receive(:get).and_return(successful_response)
    result = ActionTextJob.perform(body)
    expect(result.first[:opengraph]['title']).to eq('Title')
  end
end
