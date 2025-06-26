# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../core/constants'
require_relative '../extractors/extraction_patterns'

# Auto-loader for dynamically creating validator classes
# Generates validator classes from configuration to eliminate manual class definitions
module RichTextExtraction
  module Validators
    # AutoLoader automatically creates validator classes based on pattern definitions.
    class AutoLoader
      # Load all validators from configuration.
      def self.load_all
        RichTextExtraction::Core::Constants::VALIDATOR_EXAMPLES.each do |symbol, config|
          create_validator_class(symbol, config)
        end
      end

      # Create a validator class for a given symbol and configuration.
      def self.create_validator_class(symbol, config)
        class_name = "#{symbol.to_s.camelize}Validator"
        return Object.const_get(class_name) if Object.const_defined?(class_name)

        klass = create_validator_class_definition(symbol, config)
        Object.const_set(class_name, klass)
        klass
      end

      # Get validator class for a symbol (create if doesn't exist).
      def self.get_validator_class(symbol)
        class_name = "#{symbol.to_s.camelize}Validator"
        return Object.const_get(class_name) if Object.const_defined?(class_name)

        config = RichTextExtraction::Core::Constants::VALIDATOR_EXAMPLES[symbol]
        return nil unless config

        create_validator_class(symbol, config)
      end

      # Check if a validator class exists.
      def self.validator_exists?(symbol)
        class_name = "#{symbol.to_s.camelize}Validator"
        Object.const_defined?(class_name)
      end

      # List all available validators.
      def self.available_validators
        RichTextExtraction::Core::Constants::VALIDATOR_EXAMPLES.keys
      end

      # Create validator class definition.
      def self.create_validator_class_definition(symbol, config)
        Class.new(BaseValidator) do
          define_method(:validate_each) do |record, attribute, value|
            validate_with_config(record, attribute, value, symbol, config)
          end
        end
      end

      # Validate with configuration.
      def self.validate_with_config(record, attribute, value, symbol, config)
        if config[:validation_method]
          validate_with_method(record, attribute, value, config[:validation_method].to_sym,
                               config[:error_message] || "is not a valid #{symbol}")
        elsif config[:regex]
          validate_with_regex(record, attribute, value, config[:regex].to_sym,
                              config[:error_message] || "is not a valid #{symbol}")
        else
          validate_with_fallback_regex(record, attribute, value, symbol, config)
        end
      end

      # Validate with fallback regex.
      def self.validate_with_fallback_regex(record, attribute, value, symbol, config)
        regex_const = "#{symbol.to_s.upcase}_REGEX"
        if RichTextExtraction::Core::Constants.const_defined?(regex_const)
          validate_with_direct_regex(record, attribute, value,
                                     RichTextExtraction::Core::Constants.const_get(regex_const),
                                     config[:error_message] || "is not a valid #{symbol}")
        else
          record.errors.add(attribute, options[:message] || "is not a valid #{symbol}")
        end
      end

      private_class_method :create_validator_class_definition, :validate_with_config, :validate_with_fallback_regex
    end
  end
end
