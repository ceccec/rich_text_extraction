# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require_relative '../helpers/validator_helpers'

module RichTextExtraction
  module Extractors
    ##
    # ExtractionPatterns provides pattern-based extraction methods for RichTextExtraction.
    #
    # This module contains regex patterns and extraction methods for various
    # types of content including identifiers, social media elements, and more.
    #
    module ExtractionPatterns
      include RichTextExtraction::Core::Constants
      include RichTextExtraction::Helpers::ValidatorHelpers
      include RichTextExtraction::Extractors::BaseExtractor

      ##
      # Extracts emails from text using the centralized regex pattern.
      #
      # @param text [String] The text to extract emails from
      # @return [Array<String>] Array of email addresses
      #
      def extract_emails(text)
        RichTextExtraction::Extractors::BaseExtractor.extract_pattern(text, EMAIL_REGEX)
      end

      ##
      # Extracts phone numbers from text using the centralized regex pattern.
      #
      # @param text [String] The text to extract phone numbers from
      # @return [Array<String>] Array of phone numbers
      #
      def extract_phone_numbers(text)
        RichTextExtraction::Extractors::BaseExtractor.extract_pattern(text, PHONE_REGEX)
      end

      ##
      # Extracts image URLs from text using the centralized regex pattern.
      #
      # @param text [String] The text to extract image URLs from
      # @return [Array<String>] Array of image URLs
      #
      def extract_image_urls(text)
        process_scan_matches(RichTextExtraction::Extractors::BaseExtractor.extract_pattern(text, IMAGE_REGEX))
      end

      ##
      # Extracts attachment URLs from text using the centralized regex pattern.
      #
      # @param text [String] The text to extract attachment URLs from
      # @return [Array<String>] Array of attachment URLs
      #
      def extract_attachment_urls(text)
        process_scan_matches(RichTextExtraction::Extractors::BaseExtractor.extract_pattern(text, ATTACHMENT_REGEX))
      end

      ##
      # Extracts Twitter handles from text using the centralized regex pattern.
      #
      # @param text [String] The text to extract Twitter handles from
      # @return [Array<String>] Array of Twitter handles (without @)
      #
      def extract_twitter_handles(text)
        RichTextExtraction::Extractors::BaseExtractor.extract_pattern(text, TWITTER_REGEX)
      end

      ##
      # Extracts markdown links from text using the centralized regex pattern.
      #
      # @param text [String] The text to extract markdown links from
      # @return [Array<Hash>] Array of hashes with :text and :url keys
      #
      def extract_markdown_links(text)
        RichTextExtraction::Extractors::BaseExtractor.extract_pattern(text, MARKDOWN_LINK_REGEX).map { |text, url| { text: text, url: url } }
      end

      ##
      # Extracts hashtags from text using the centralized regex pattern.
      #
      # @param text [String] The text to extract hashtags from
      # @return [Array<String>] Array of hashtags (without #)
      #
      def extract_hashtags(text)
        RichTextExtraction::Extractors::BaseExtractor.extract_pattern(text, HASHTAG_REGEX)
      end

      ##
      # Extracts mentions from text using the centralized regex pattern.
      #
      # @param text [String] The text to extract mentions from
      # @return [Array<String>] Array of mentions (without @)
      #
      def extract_mentions(text)
        RichTextExtraction::Extractors::BaseExtractor.extract_pattern(text, MENTION_REGEX)
      end

      ##
      # Creates an excerpt of text with specified length.
      #
      # @param text [String] The text to excerpt
      # @param length [Integer] The maximum length of the excerpt
      # @return [String] The excerpted text
      #
      def create_excerpt(text, length = DEFAULT_EXCERPT_LENGTH)
        return '' unless text.is_a?(String)

        text.length > length ? "#{text[0...length].rstrip}…" : text
      end

      ##
      # Processes scan results to handle both single matches and arrays.
      #
      # @param matches [Array] The scan matches
      # @return [Array<String>] Processed matches
      #
      def process_scan_matches(matches)
        matches.map { |match| match.is_a?(Array) ? match[0] : match }
      end

      # === Identifier Patterns ===

      # ISBN-10 or ISBN-13 (with or without hyphens or spaces)
      ISBN_REGEX = /\A(?:97[89][-\s]?\d{1,5}[-\s]?\d{1,7}[-\s]?\d{1,7}[-\s]?\d|\d{9}[\dXx])\z/u

      # EAN-13 barcode (13 digits)
      EAN13_REGEX = /\A\d{13}\z/u

      # UPC-A barcode (12 digits)
      UPCA_REGEX = /\A\d{12}\z/u

      # UUID/GUID (RFC 4122)
      UUID_REGEX = /\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\z/u

      # Credit card numbers (Luhn, 13-16 digits, with spaces or dashes)
      CREDIT_CARD_REGEX = /\A(?:\d[ -]*?){13,16}\z/u

      # Hex color (CSS)
      HEX_COLOR_REGEX = /\A#(?:[0-9a-fA-F]{3}){1,2}\z/u

      # IP address (IPv4)
      IP_REGEX = /\A(?:\d{1,3}\.){3}\d{1,3}\z/u

      # VIN (17 chars, ISO 3779)
      VIN_REGEX = /\A[A-HJ-NPR-Z0-9]{17}\z/iu

      # IMEI (15 digits)
      IMEI_REGEX = /\A\d{15}\z/u

      # ISSN (8 digits, with optional hyphen)
      ISSN_REGEX = /\A\d{4}-?\d{3}[\dXx]\z/u

      # MAC address (colon or dash separated, full string)
      MAC_ADDRESS_REGEX = /\A(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\z/u

      # IBAN (ISO 13616, 15-34 chars, simplified)
      IBAN_REGEX = /\A[A-Z]{2}\d{2}[A-Z0-9]{11,30}\z/u

      # Hashtag (word characters)
      HASHTAG_PATTERN = /\A\w+\z/u

      # Mention (word characters)
      MENTION_PATTERN = /\A\w+\z/u

      # Twitter handle (1-15 word characters)
      TWITTER_HANDLE_PATTERN = /\A\w{1,15}\z/u

      # Instagram handle (1-30 word characters or periods)
      INSTAGRAM_HANDLE_PATTERN = /\A[\w.]{1,30}\z/u

      # URL (http/https)
      URL_PATTERN = %r{\Ahttps?://[^\s]+\z}u

      # === DRY Metaprogramming: Pattern-based Extractors ===
      require_relative '../core/constants'
      RichTextExtraction::Core::Constants::VALIDATOR_EXAMPLES.each do |key, meta|
        next unless RichTextExtraction::Helpers::ValidatorHelpers.should_process_validator?(key, meta)

        method_name = RichTextExtraction::Helpers::ValidatorHelpers.validator_method_name(key)
        regex_const = RichTextExtraction::Helpers::ValidatorHelpers.get_regex_constant(meta)

        # Skip if method is already manually defined
        next if method_defined?(method_name)

        define_method(method_name) do |text|
          return [] unless text.is_a?(String)

          regex = RichTextExtraction::Extractors::ExtractionPatterns.const_get(regex_const)
          text.scan(regex)
        end
      end
    end
  end
end
