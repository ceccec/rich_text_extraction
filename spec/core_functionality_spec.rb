# frozen_string_literal: true

##
# Core functionality tests for RichTextExtraction
#
# Only includes version information now; other tests have been moved to feature-focused files.

require 'spec_helper'
require_relative 'support/shared_contexts'

RSpec.describe RichTextExtraction do
  describe 'VERSION' do
    it 'is not nil' do
      expect(described_class::VERSION).not_to be_nil
    end
  end
end
