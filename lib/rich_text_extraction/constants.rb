# frozen_string_literal: true

module RichTextExtraction
  ##
  # Constants provides centralized regex patterns and common values used across RichTextExtraction.
  # This module helps maintain consistency and reduces duplication.
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

    # Application-wide valid/invalid examples for all validators
    # NOTE: Keys are validator symbols (e.g., :isbn, :vin) for Rails compatibility.
    # NOTE: Regex values are string names to avoid circular dependency. Use .resolve_validator_regex(:symbol) to get the actual regex.
    VALIDATOR_EXAMPLES = {
      isbn: {
        valid: ['978-3-16-148410-0', '0-306-40615-2'],
        invalid: ['978-3-16-148410-1', '123'],
        regex: nil, # Uses validation method
        schema_type: 'Book',
        schema_property: 'isbn',
        description: 'International Standard Book Number (schema.org/Book/isbn)'
      },
      vin: {
        valid: ['1HGCM82633A004352'],
        invalid: %w[1HGCM82633A004353 123],
        regex: 'VIN_REGEX',
        schema_type: 'Vehicle',
        schema_property: 'vehicleIdentificationNumber',
        description: 'Vehicle Identification Number (schema.org/Vehicle/vehicleIdentificationNumber)'
      },
      issn: {
        valid: ['2049-3630'],
        invalid: %w[2049-3631 123],
        regex: nil, # Uses validation method
        schema_type: 'PublicationIssue',
        schema_property: 'issn',
        description: 'International Standard Serial Number (schema.org/PublicationIssue/issn)'
      },
      iban: {
        valid: ['GB82WEST12345698765432'],
        invalid: %w[GB82WEST12345698765431 123],
        regex: 'IBAN_REGEX',
        schema_type: 'BankAccount',
        schema_property: 'identifier',
        description: 'International Bank Account Number (no direct schema.org property, using identifier)'
      },
      luhn: {
        valid: ['4111 1111 1111 1111', '79927398713'],
        invalid: ['4111 1111 1111 1112', '123'],
        regex: 'CREDIT_CARD_REGEX',
        schema_type: 'CreditCard',
        schema_property: 'identifier',
        description: 'Credit card number (schema.org/CreditCard/identifier, Luhn validated)'
      },
      ean13: {
        valid: ['4006381333931'],
        invalid: %w[4006381333932 123],
        regex: 'EAN13_REGEX',
        schema_type: 'Product',
        schema_property: 'gtin13',
        description: 'EAN-13 barcode (schema.org/Product/gtin13)',
        error_message: 'is not a valid EAN-13 barcode'
      },
      upca: {
        valid: ['036000291452'],
        invalid: %w[036000291453 123],
        regex: 'UPCA_REGEX',
        schema_type: 'Product',
        schema_property: 'gtin12',
        description: 'UPC-A barcode (schema.org/Product/gtin12)',
        error_message: 'is not a valid UPC-A barcode'
      },
      uuid: {
        valid: ['123e4567-e89b-12d3-a456-426614174000'],
        invalid: %w[123e4567-e89b-12d3-a456-42661417400Z 123],
        regex: 'UUID_REGEX',
        schema_type: 'Thing',
        schema_property: 'identifier',
        description: 'UUID (schema.org/Thing/identifier)',
        error_message: 'is not a valid UUID'
      },
      hex_color: {
        valid: ['#fff', '#abcdef'],
        invalid: ['#ggg', '123'],
        regex: 'HEX_COLOR_REGEX',
        schema_type: 'Thing',
        schema_property: 'color',
        description: 'Hex color (schema.org/Thing/color)',
        error_message: 'is not a valid hex color'
      },
      ip: {
        valid: ['192.168.1.1'],
        invalid: ['999.999.999.999', 'abc'],
        regex: 'IP_REGEX',
        schema_type: 'Thing',
        schema_property: 'identifier',
        description: 'IPv4 address (schema.org/Thing/identifier)',
        error_message: 'is not a valid IPv4 address'
      },
      mac_address: {
        valid: ['00:1A:2B:3C:4D:5E'],
        invalid: ['00:1A:2B:3C:4D:5Z', '123'],
        regex: 'MAC_ADDRESS_REGEX',
        schema_type: 'Thing',
        schema_property: 'identifier',
        description: 'MAC address (schema.org/Thing/identifier)',
        error_message: 'is not a valid MAC address'
      },
      hashtag: {
        valid: %w[hashtag test123],
        invalid: ['#hashtag', 'test 123', ''],
        regex: 'HASHTAG_PATTERN',
        schema_type: 'Thing',
        schema_property: 'identifier',
        description: 'Hashtag (no direct schema.org property, using identifier)',
        error_message: 'is not a valid hashtag'
      },
      mention: {
        valid: %w[mention user123],
        invalid: ['@mention', 'user name', ''],
        regex: 'MENTION_PATTERN',
        schema_type: 'Person',
        schema_property: 'identifier',
        description: 'Mention (no direct schema.org property, using identifier)',
        error_message: 'is not a valid mention'
      },
      twitter_handle: {
        valid: %w[jack user123],
        invalid: ['user_name_too_long_for_twitter', ''],
        regex: 'TWITTER_HANDLE_PATTERN',
        schema_type: 'Person',
        schema_property: 'sameAs',
        description: 'Twitter handle (schema.org/Person/sameAs, for social profile URLs)',
        error_message: 'is not a valid Twitter handle'
      },
      instagram_handle: {
        valid: %w[instauser user123],
        invalid: ['user_name_that_is_way_too_long_for_instagram_because_it_is_over_30_chars', ''],
        regex: 'INSTAGRAM_HANDLE_PATTERN',
        schema_type: 'Person',
        schema_property: 'sameAs',
        description: 'Instagram handle (schema.org/Person/sameAs, for social profile URLs)',
        error_message: 'is not a valid Instagram handle'
      },
      url: {
        valid: ['https://example.com', 'http://test.com'],
        invalid: ['not a url', 'ftp://example.com'],
        regex: 'URL_PATTERN',
        schema_type: 'Thing',
        schema_property: 'url',
        description: 'URL (schema.org/Thing/url)'
      }
    }.freeze

    # Helper to resolve the regex for a validator symbol at runtime
    def self.resolve_validator_regex(symbol)
      entry = VALIDATOR_EXAMPLES[symbol]
      return nil unless entry && entry[:regex]

      require_relative 'extraction_patterns'
      RichTextExtraction::ExtractionPatterns.const_get(entry[:regex])
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
end
