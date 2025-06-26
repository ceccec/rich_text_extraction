# frozen_string_literal: true

module RichTextExtraction
  module Core
    ##
    # Constants used throughout RichTextExtraction
    #
    # This module contains all the constants, regex patterns, and configuration
    # values used by the gem. It's organized by category for easy maintenance.
    #
    module Constants
      # Email regex pattern
      EMAIL_REGEX = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z]{2,}\b/i

      # Phone number regex pattern
      PHONE_REGEX = /\b\+?\d[\d\s\-()]{7,}\b/

      # Date regex patterns (ISO and US formats)
      DATE_REGEX = %r{\b\d{4}-\d{2}-\d{2}\b|\b\d{2}/\d{2}/\d{4}\b}

      # Image file extensions
      IMAGE_EXTENSIONS = %w[jpg jpeg png gif svg webp].freeze

      # Attachment file extensions
      ATTACHMENT_EXTENSIONS = %w[pdf docx doc xlsx xls pptx ppt txt csv zip rar 7z].freeze

      # Image URL regex pattern
      IMAGE_REGEX = %r{https?://[^\s]+?\.(#{IMAGE_EXTENSIONS.join('|')})}

      # Attachment URL regex pattern
      ATTACHMENT_REGEX = %r{https?://[\w\-.?,'/\\+&%$#_=:()~]+\.(#{ATTACHMENT_EXTENSIONS.join('|')})}i

      # Twitter handle regex pattern
      TWITTER_REGEX = /@([A-Za-z0-9_]{1,15})/

      # Markdown link regex pattern
      MARKDOWN_LINK_REGEX = %r{\[([^\]]+)\]\((https?://[^)]+)\)}

      # Hashtag regex pattern
      HASHTAG_REGEX = /#(\w+)/

      # Mention regex pattern
      MENTION_REGEX = /@(\w+)/

      # Default cache TTL in seconds (1 hour)
      DEFAULT_CACHE_TTL = 3600

      # Default excerpt length
      DEFAULT_EXCERPT_LENGTH = 300

      # Default OpenGraph timeout in seconds
      DEFAULT_OPENGRAPH_TIMEOUT = 15

      # Default max redirects
      DEFAULT_MAX_REDIRECTS = 3

      # Default user agent
      DEFAULT_USER_AGENT = 'RichTextExtraction/1.0'

      # Default cache prefix
      DEFAULT_CACHE_PREFIX = 'rte'

      # Default cache store
      DEFAULT_CACHE_STORE = :memory_store

      # Shared error messages for validators
      ERROR_MESSAGES = {
        ean13: 'is not a valid EAN-13 barcode',
        upca: 'is not a valid UPC-A barcode',
        uuid: 'is not a valid UUID',
        hex_color: 'is not a valid hex color',
        ip: 'is not a valid IPv4 address',
        mac_address: 'is not a valid MAC address',
        hashtag: 'is not a valid hashtag',
        mention: 'is not a valid mention',
        twitter_handle: 'is not a valid Twitter handle',
        instagram_handle: 'is not a valid Instagram handle'
      }.freeze

      # Helper for schema.org description
      def self.schema_description(type, property)
        "#{type} (schema.org/#{type}/#{property})"
      end

      # Validator factory - creates any type of validator based on configuration
      def self.create_validator(valid:, invalid:, schema_type:, schema_property:,
                                regex: nil, validation_method: nil, error_message: nil,
                                description: nil)
        build_validator_entry(
          valid: valid,
          invalid: invalid,
          schema_type: schema_type,
          schema_property: schema_property,
          description: description || schema_description(schema_type, schema_property),
          regex: regex,
          validation_method: validation_method,
          error_message: error_message
        )
      end

      # Configuration for convenience validator methods
      VALIDATOR_TYPES = {
        standard: { schema_type: nil, schema_property: nil }, # Must be provided
        product: { schema_type: 'Product', schema_property: nil }, # Must provide schema_property
        social: { schema_type: 'Person', schema_property: 'sameAs' },
        thing: { schema_type: 'Thing', schema_property: 'identifier' }
      }.freeze

      # Generate convenience validator methods dynamically
      VALIDATOR_TYPES.each do |type, defaults|
        define_singleton_method("#{type}_validator") do |valid:, invalid:, **options|
          schema_type = options[:schema_type] || defaults[:schema_type]
          schema_property = options[:schema_property] || defaults[:schema_property]

          unless schema_type && schema_property
            raise ArgumentError,
                  "schema_type and schema_property required for #{type}_validator"
          end

          create_validator(
            valid: valid,
            invalid: invalid,
            schema_type: schema_type,
            schema_property: schema_property,
            regex: options[:regex],
            validation_method: options[:validation_method],
            error_message: options[:error_message]
          )
        end
      end

      # Helper method to build validator example entries
      def self.build_validator_entry(valid:, invalid:, schema_type:, schema_property:, description:,
                                     regex: nil, validation_method: nil, error_message: nil)
        {
          valid: valid,
          invalid: invalid,
          regex: regex,
          validation_method: validation_method,
          schema_type: schema_type,
          schema_property: schema_property,
          description: description,
          error_message: error_message
        }.compact
      end

      # Application-wide valid/invalid examples for all validators
      # NOTE: Keys are validator symbols (e.g., :isbn, :vin) for Rails compatibility.
      # NOTE: Regex values are string names to avoid circular dependency.
      # Use .resolve_validator_regex(:symbol) to get the actual regex.
      VALIDATOR_EXAMPLES = {
        isbn: standard_validator(
          valid: ['978-3-16-148410-0', '0-306-40615-2'],
          invalid: ['978-3-16-148410-1', '123'],
          validation_method: 'valid_isbn?',
          schema_type: 'Book',
          schema_property: 'isbn'
        ),
        vin: standard_validator(
          valid: ['1HGCM82633A004352'],
          invalid: %w[1HGCM82633A004353 123],
          regex: 'VIN_REGEX',
          validation_method: 'valid_vin?',
          schema_type: 'Vehicle',
          schema_property: 'vehicleIdentificationNumber'
        ),
        issn: standard_validator(
          valid: ['2049-3630'],
          invalid: %w[2049-3631 123],
          validation_method: 'valid_issn?',
          schema_type: 'PublicationIssue',
          schema_property: 'issn'
        ),
        iban: build_validator_entry(
          valid: ['GB82WEST12345698765432'],
          invalid: %w[GB82WEST12345698765431 123],
          regex: 'IBAN_REGEX',
          validation_method: 'valid_iban?',
          schema_type: 'BankAccount',
          schema_property: 'identifier',
          description: 'International Bank Account Number (no direct schema.org property, using identifier)'
        ),
        luhn: build_validator_entry(
          valid: ['4111 1111 1111 1111', '79927398713'],
          invalid: ['4111 1111 1111 1112', '123'],
          regex: 'CREDIT_CARD_REGEX',
          validation_method: 'luhn_valid?',
          schema_type: 'CreditCard',
          schema_property: 'identifier',
          description: 'Credit card number (schema.org/CreditCard/identifier, Luhn validated)'
        ),
        ean13: product_validator(
          valid: ['4006381333931'],
          invalid: %w[4006381333932 123],
          schema_property: 'gtin13',
          regex: 'EAN13_REGEX',
          error_message: ERROR_MESSAGES[:ean13]
        ),
        upca: product_validator(
          valid: ['036000291452'],
          invalid: %w[036000291453 123],
          schema_property: 'gtin12',
          regex: 'UPCA_REGEX',
          error_message: ERROR_MESSAGES[:upca]
        ),
        uuid: thing_validator(
          valid: ['123e4567-e89b-12d3-a456-426614174000'],
          invalid: %w[123e4567-e89b-12d3-a456-42661417400Z 123],
          regex: 'UUID_REGEX',
          error_message: ERROR_MESSAGES[:uuid]
        ),
        hex_color: build_validator_entry(
          valid: ['#fff', '#abcdef'],
          invalid: ['#ggg', '123'],
          regex: 'HEX_COLOR_REGEX',
          schema_type: 'Thing',
          schema_property: 'color',
          description: schema_description('Thing', 'color'),
          error_message: ERROR_MESSAGES[:hex_color]
        ),
        ip: thing_validator(
          valid: ['192.168.1.1'],
          invalid: ['999.999.999.999', 'abc'],
          regex: 'IP_REGEX',
          error_message: ERROR_MESSAGES[:ip]
        ),
        mac_address: thing_validator(
          valid: ['00:1A:2B:3C:4D:5E'],
          invalid: ['00:1A:2B:3C:4D:5Z', '123'],
          regex: 'MAC_ADDRESS_REGEX',
          error_message: ERROR_MESSAGES[:mac_address]
        ),
        hashtag: build_validator_entry(
          valid: %w[hashtag test123],
          invalid: ['#hashtag', 'test 123', ''],
          regex: 'HASHTAG_PATTERN',
          schema_type: 'Thing',
          schema_property: 'identifier',
          description: 'Hashtag (no direct schema.org property, using identifier)',
          error_message: ERROR_MESSAGES[:hashtag]
        ),
        mention: build_validator_entry(
          valid: %w[mention user123],
          invalid: ['@mention', 'user name', ''],
          regex: 'MENTION_PATTERN',
          schema_type: 'Person',
          schema_property: 'identifier',
          description: 'Mention (no direct schema.org property, using identifier)',
          error_message: ERROR_MESSAGES[:mention]
        ),
        twitter_handle: social_validator(
          valid: %w[jack user123],
          invalid: ['user_name_too_long_for_twitter', ''],
          regex: 'TWITTER_HANDLE_PATTERN',
          error_message: ERROR_MESSAGES[:twitter_handle]
        ),
        instagram_handle: social_validator(
          valid: %w[instauser user123],
          invalid: ['user_name_that_is_way_too_long_for_instagram_because_it_is_over_30_chars', ''],
          regex: 'INSTAGRAM_HANDLE_PATTERN',
          error_message: ERROR_MESSAGES[:instagram_handle]
        ),
        url: standard_validator(
          valid: ['https://example.com', 'http://test.com'],
          invalid: ['not a url', 'ftp://example.com'],
          regex: 'URL_PATTERN',
          schema_type: 'Thing',
          schema_property: 'url'
        )
      }.freeze

      # Helper to resolve the regex for a validator symbol at runtime
      def self.resolve_validator_regex(symbol)
        entry = VALIDATOR_EXAMPLES[symbol]
        return nil unless entry && entry[:regex]

        require_relative '../extractors/extraction_patterns'
        RichTextExtraction::Extractors::ExtractionPatterns.const_get(entry[:regex])
      end

      # Helper to generate schema.org JSON-LD for a validated value
      def self.to_jsonld(symbol, value)
        entry = VALIDATOR_EXAMPLES[symbol]
        return nil unless entry && entry[:schema_type] && entry[:schema_property]

        {
          "@context": 'https://schema.org',
          "@type": entry[:schema_type],
          entry[:schema_property].to_sym => value
        }.to_json
      end
    end

    module Patterns
      EMAIL = /\b[\w+\-.]+@[a-z\d-]+(?:\.[a-z\d-]+)*\.[a-z]+\b/i
      LINK  = %r{https?://[^\s]+}
      PHONE = /\+?1?\d{10,15}/
      HASHTAG = /#\w+/
      MENTION = /@\w+/
      # Add more patterns as needed
    end
  end
end
