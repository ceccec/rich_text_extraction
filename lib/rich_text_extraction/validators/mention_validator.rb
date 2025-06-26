# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../extractors/extraction_patterns'

# Validator for social media mention format
# Validates @mentions in social media content
module RichTextExtraction
  module Validators
    class MentionValidator < BaseValidator
      def validate_each(record, attribute, value)
        validate_with_method(record, attribute, value, :valid_mention?, 'is not a valid mention')
      end
    end
  end
end
