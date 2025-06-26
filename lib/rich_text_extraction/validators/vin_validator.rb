# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../extractors/extraction_patterns'

# Validator for VIN (Vehicle Identification Number) format
# Validates 17-character vehicle identification numbers
module RichTextExtraction
  module Validators
    class VinValidator < BaseValidator
      def validate_each(record, attribute, value)
        validate_with_method(record, attribute, value, :valid_vin?, 'is not a valid VIN')
      end
    end
  end
end
