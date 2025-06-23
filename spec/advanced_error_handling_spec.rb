# frozen_string_literal: true

##
# Advanced error handling tests for RichTextExtraction
#
# Tests error handling in OpenGraph extraction.

require 'spec_helper'
require 'rich_text_extraction'
require 'active_support'
require 'active_support/cache'
require_relative 'support/shared_contexts'

RSpec.describe 'Advanced error handling' do
  context 'when handling errors in OpenGraph extraction' do
    include_context 'with error extractor'

    it 'returns an error in the opengraph hash' do
      result = extractor.link_objects(with_opengraph: true).first[:opengraph]
      expect(result).to have_key(:error)
    end
  end
end
