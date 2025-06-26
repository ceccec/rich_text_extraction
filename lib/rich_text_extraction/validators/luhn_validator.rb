# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../extractors/validators'

# Validator for Luhn algorithm checksum
# Validates numbers using the Luhn algorithm (credit cards, etc.)
module RichTextExtraction
  module Validators
    class LuhnValidator < BaseValidator
      def validate_each(record, attribute, value)
        validate_with_method(record, attribute, value, :luhn_valid?, 'is not a valid Luhn number')
      end
    end
  end
end
