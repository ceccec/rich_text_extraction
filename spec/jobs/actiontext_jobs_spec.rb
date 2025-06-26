# frozen_string_literal: true

##
# ActionText and background job tests for RichTextExtraction
#
# Tests ActionText integration and background job functionality.

require 'spec_helper'

RSpec.describe 'ActionText and background jobs' do
  include_context 'with Rails integration setup'

  include_examples 'works with background jobs'
end
