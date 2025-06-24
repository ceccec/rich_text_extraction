# frozen_string_literal: true

require_relative '../extractors/validators'
require_relative '../extraction_patterns'

class VinValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    result = RichTextExtraction::Extractors::Validators.valid_vin?(value)
    Rails.logger.debug { "[DEBUG] VinValidator: value=#{value.inspect}, result=#{result}" }
    return if result

    record.errors.add(attribute, options[:message] || 'is not a valid VIN')
  end
end
