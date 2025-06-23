# frozen_string_literal: true

##
# Advanced background job tests for RichTextExtraction
#
# Tests using the gem in background job scenarios.

require 'spec_helper'
require_relative 'support/shared_contexts'

RSpec.describe 'Advanced background job usage' do
  include_context 'with HTTParty stubs'

  context 'when used in a background job (stub)' do
    it 'returns the correct OpenGraph title' do
      allow(HTTParty).to receive(:get).and_return(successful_response)
      result = DummyJob.perform('https://example.com')
      expect(result.first[:opengraph]['title']).to eq('Title')
    end
  end
end 