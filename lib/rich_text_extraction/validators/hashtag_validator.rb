# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../extractors/extraction_patterns'

# Validator for hashtag format
# Validates social media hashtags (e.g., #ruby, #rails)
module RichTextExtraction
  module Validators
    class HashtagValidator < BaseValidator
      def validate_each(record, attribute, value)
        validate_with_method(record, attribute, value, :valid_hashtag?, 'is not a valid hashtag')
      end
    end
  end
end
