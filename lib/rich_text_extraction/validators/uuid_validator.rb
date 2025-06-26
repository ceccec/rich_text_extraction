# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../extractors/extraction_patterns'

# Validator for UUID (Universally Unique Identifier) format
# Validates UUID v4 format strings
module RichTextExtraction
  module Validators
    class UuidValidator < BaseValidator
      def validate_each(record, attribute, value)
        validate_with_method(record, attribute, value, :valid_uuid?, 'is not a valid UUID')
      end
    end
  end
end
