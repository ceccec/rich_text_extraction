# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../extractors/validators'

module RichTextExtraction
  module Validators
    # Validator for ISSN (International Standard Serial Number) format
    # Validates 8 digit ISSN codes for serial publications
    class IssnValidator < BaseValidator
      def validate_each(record, attribute, value)
        validate_with_method(record, attribute, value, :valid_issn?, 'is not a valid ISSN')
      end
    end
  end
end
