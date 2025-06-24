# frozen_string_literal: true

require_relative '../extractors/validators'
require_relative '../extraction_patterns'

class LuhnValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    result = RichTextExtraction::Extractors::Validators.luhn_valid?(value)
    Rails.logger.debug { "[DEBUG] LuhnValidator: value=#{value.inspect}, result=#{result}" }
    return if result

    record.errors.add(attribute, options[:message] || 'is not a valid number (Luhn check failed)')
  end
end
