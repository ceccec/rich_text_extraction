# frozen_string_literal: true

##
# Advanced background job tests for RichTextExtraction
#
# Tests using the gem in background job scenarios.

require 'spec_helper'

RSpec.describe 'Advanced background job usage' do
  include_context 'with Rails integration setup'

  include_examples 'works with background jobs'
end
