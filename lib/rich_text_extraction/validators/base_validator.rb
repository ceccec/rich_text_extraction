# frozen_string_literal: true

require_relative '../extractors/extraction_patterns'

module RichTextExtraction
  module Validators
    # Base class for all RichTextExtraction validators
    # Provides common functionality to reduce code duplication
    class BaseValidator < ActiveModel::EachValidator
      include ActiveModel::Validations

      def self.valid?(value)
        new.valid?(value)
      end

      def valid?(value)
        # Default implementation, override in subclasses
        true
      end

      private

      # Validate using a regex pattern
      def validate_with_regex(record, attribute, value, regex_const, error_message)
        regex = RichTextExtraction::Extractors::ExtractionPatterns.const_get(regex_const)
        val = value.to_s.strip
        log_debug("#{self.class.name}: value='#{val}', regex=#{regex.inspect}")

        result = val.match?(regex)
        return if result

        record.errors.add(attribute, options[:message] || error_message)
      end

      # Validate using a direct regex
      def validate_with_direct_regex(record, attribute, value, regex, error_message)
        result = value.to_s.match?(regex)
        log_debug("#{self.class.name}: value=#{value.inspect}, result=#{result}")

        return if result

        record.errors.add(attribute, options[:message] || error_message)
      end

      # Validate using a validation method
      def validate_with_method(record, attribute, value, validation_method, error_message)
        method_sym = validation_method.to_sym
        unless RichTextExtraction::Extractors::Validators.respond_to?(method_sym)
          log_debug("[ERROR] Validation method '#{method_sym}' not found on RichTextExtraction::Extractors::Validators")
          raise NoMethodError, "Validation method '#{method_sym}' not found on RichTextExtraction::Extractors::Validators"
        end
        result = RichTextExtraction::Extractors::Validators.send(method_sym, value)
        log_debug("#{self.class.name}: value=#{value.inspect}, result=#{result}")
        return if result

        record.errors.add(attribute, options[:message] || error_message)
      end

      # Log debug message if Rails logger is available
      def log_debug(message)
        return unless defined?(::Rails) && ::Rails.logger

        ::Rails.logger.debug { "[DEBUG] #{message}" }
      end

      # Initialize the validator with options
      # @param options [Hash] Options for the validator
      def initialize(options = {})
        @options = options
      end
    end
  end
end
