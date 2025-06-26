# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../extractors/extraction_patterns'

# Validator for hexadecimal color format
# Validates 3 or 6 digit hex color codes (e.g., #fff, #ffffff)
module RichTextExtraction
  module Validators
    class HexColorValidator < BaseValidator
      def validate_each(record, attribute, value)
        validate_with_method(record, attribute, value, :valid_hex_color?, 'is not a valid hex color')
      end
    end
  end
end
