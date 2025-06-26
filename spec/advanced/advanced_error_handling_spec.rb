# frozen_string_literal: true

##
# Advanced error handling tests for RichTextExtraction
#
# Tests error handling in OpenGraph extraction.

require 'spec_helper'

RSpec.describe 'Advanced error handling' do
  include_context 'with error setup'

  include_examples 'handles errors gracefully'
end
