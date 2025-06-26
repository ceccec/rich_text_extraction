# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../extractors/extraction_patterns'

module RichTextExtraction
  module Validators
    # Validator for Twitter handle format
    # Validates Twitter usernames (e.g., @username)
    class TwitterHandleValidator < BaseValidator
      def validate_each(record, attribute, value)
        validate_with_method(record, attribute, value, :valid_twitter_handle?, 'is not a valid Twitter handle')
      end
    end
  end
end
