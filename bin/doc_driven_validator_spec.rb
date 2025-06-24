#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rspec'
require 'active_model'
require_relative '../lib/rich_text_extraction/constants'
require_relative '../lib/rich_text_extraction/validator_api'

# Map validator symbol to class name
def validator_class_for(symbol)
  class_name = "#{symbol.to_s.camelize}Validator"
  begin
    Object.const_get(class_name)
  rescue StandardError
    nil
  end
end

def create_stub_validator(symbol, regex_const)
  klass_name = "#{symbol.to_s.camelize}Validator"
  regex = begin
    RichTextExtraction::ExtractionPatterns.const_get(regex_const)
  rescue StandardError
    nil
  end
  return nil unless regex

  klass = Class.new(ActiveModel::EachValidator) do
    define_method(:validate_each) do |record, attribute, value|
      return if value.to_s.match?(regex)

      record.errors.add(attribute, options[:message] || "is not a valid #{symbol}")
    end
  end
  Object.const_set(klass_name, klass)
  klass
end

examples = RichTextExtraction::Constants::VALIDATOR_EXAMPLES
stubs_created = []
missing_untestable = []

RSpec.describe 'Doc-driven Validator Examples' do
  examples.each_key do |validator|
    ex = RichTextExtraction::ValidatorAPI.examples(validator)
    context "#{validator} validator" do
      if ex[:valid] || ex[:invalid]
        Array(ex[:valid]).each do |example|
          it "accepts valid example: #{example.inspect}" do
            result = RichTextExtraction::ValidatorAPI.validate(validator, example)
            expect(result[:valid]).to be true
          end
        end
        Array(ex[:invalid]).each do |example|
          it "rejects invalid example: #{example.inspect}" do
            result = RichTextExtraction::ValidatorAPI.validate(validator, example)
            expect(result[:valid]).to be false
          end
        end
      else
        it "has a validator class for #{validator}" do
          missing_untestable << validator
          raise "Validator class for #{validator} is missing and cannot be stubbed. Please implement #{validator.to_s.camelize}Validator."
        end
      end
    end
  end
end

# Run the suite
exit_code = RSpec::Core::Runner.run([])

Rails.logger.debug "\n--- Doc-driven Validator Test Summary ---"
if stubs_created.any?
  Rails.logger.debug do
    "Stub validators auto-generated for: #{stubs_created.map(&:to_s).join(', ')}"
  end
end
if missing_untestable.any?
  Rails.logger.debug { "Missing/uncovered validators: #{missing_untestable.map(&:to_s).join(', ')}" }
end
Rails.logger.debug 'All test execution was strictly limited to validator logic.'
exit exit_code
