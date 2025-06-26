# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../extractors/extraction_patterns'

# Validator for IP address format
# Validates IPv4 and IPv6 addresses
module RichTextExtraction
  module Validators
    class IpValidator < BaseValidator
      def validate_each(record, attribute, value)
        validate_with_method(record, attribute, value, :valid_ip?, 'is not a valid IP address')
      end
    end
  end
end
