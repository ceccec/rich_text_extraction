# frozen_string_literal: true

##
# Advanced view helper tests for RichTextExtraction
#
# Tests view helper rendering with different formats.

require 'spec_helper'

RSpec.describe 'Advanced view helper usage' do
  include_context 'with OpenGraph setup'

  include_examples 'renders OpenGraph previews', :markdown
  include_examples 'renders OpenGraph previews', :text
end
