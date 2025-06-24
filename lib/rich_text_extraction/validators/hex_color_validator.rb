# frozen_string_literal: true

require_relative '../extraction_patterns'

class HexColorValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    result = value.to_s.match?(RichTextExtraction::ExtractionPatterns::HEX_COLOR_REGEX)
    Rails.logger.debug { "[DEBUG] HexColorValidator: value=#{value.inspect}, result=#{result}" }
    return if result

    record.errors.add(attribute, options[:message] || 'is not a valid hex color')
  end
end
