# frozen_string_literal: true

##
# Advanced error handling tests for RichTextExtraction
#
# Tests error handling in OpenGraph extraction.

require 'spec_helper'
require_relative 'support/shared_contexts'

RSpec.describe 'Advanced error handling' do
  context 'when handling errors in OpenGraph extraction' do
    let(:extractor) { RichTextExtraction::Extractor.new('https://badurl.com') }

    it 'returns an error in the opengraph hash' do
      allow(HTTParty).to receive(:get).and_raise(StandardError.new('fail'))
      result = extractor.link_objects(with_opengraph: true)
      expect(result.first[:opengraph][:error]).to eq('fail')
    end
  end
end 