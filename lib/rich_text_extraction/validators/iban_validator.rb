# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../extractors/extraction_patterns'

# Validator for IBAN (International Bank Account Number) format
# Validates international bank account numbers
module RichTextExtraction
  module Validators
    class IbanValidator < BaseValidator
      def validate_each(record, attribute, value)
        validate_with_method(record, attribute, value, :valid_iban?, 'is not a valid IBAN')
      end
    end
  end
end
