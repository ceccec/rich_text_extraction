# frozen_string_literal: true

require_relative '../extraction_patterns'

class UuidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    result = value.to_s.match?(RichTextExtraction::ExtractionPatterns::UUID_REGEX)
    Rails.logger.debug { "[DEBUG] UuidValidator: value=#{value.inspect}, result=#{result}" }
    return if result

    record.errors.add(attribute, options[:message] || 'is not a valid UUID')
  end
end
