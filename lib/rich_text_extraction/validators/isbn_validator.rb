# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../extractors/validators'

module RichTextExtraction
  module Validators
    # Validator for ISBN (International Standard Book Number) format
    # Validates 10 and 13 digit ISBN codes
    class IsbnValidator < BaseValidator
      def validate_each(record, attribute, value)
        validate_with_method(record, attribute, value, :valid_isbn?, 'is not a valid ISBN')
      end
    end
  end
end
