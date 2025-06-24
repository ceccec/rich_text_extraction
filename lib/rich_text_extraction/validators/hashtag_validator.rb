# frozen_string_literal: true

require_relative '../extraction_patterns'

class HashtagValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    regex = RichTextExtraction::ExtractionPatterns.const_get(:HASHTAG_PATTERN)
    val = value.to_s.strip
    Rails.logger.debug { "[DEBUG] HashtagValidator: value='#{val}', regex=#{regex.inspect}" }
    result = val.match?(regex)
    return if result

    record.errors.add(attribute, options[:message] || 'is not a valid hashtag')
  end
end
