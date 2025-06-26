# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../extractors/extraction_patterns'

# Validator for Instagram handle format
# Validates Instagram usernames (e.g., @username)
module RichTextExtraction
  module Validators
    class InstagramHandleValidator < BaseValidator
      def validate_each(record, attribute, value)
        validate_with_method(record, attribute, value, :valid_instagram_handle?, 'is not a valid Instagram handle')
      end
    end
  end
end
