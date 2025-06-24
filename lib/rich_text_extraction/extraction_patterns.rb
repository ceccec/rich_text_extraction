# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

module RichTextExtraction
  ##
  # ExtractionPatterns provides centralized extraction methods for various content types.
  # This module eliminates duplication and provides consistent extraction logic.
  #
  module ExtractionPatterns
    include Constants

    ##
    # Extracts emails from text using the centralized regex pattern.
    #
    # @param text [String] The text to extract emails from
    # @return [Array<String>] Array of email addresses
    #
    def extract_emails(text)
      return [] unless text.is_a?(String)

      text.scan(EMAIL_REGEX)
    end

    ##
    # Extracts phone numbers from text using the centralized regex pattern.
    #
    # @param text [String] The text to extract phone numbers from
    # @return [Array<String>] Array of phone numbers
    #
    def extract_phone_numbers(text)
      return [] unless text.is_a?(String)

      text.scan(PHONE_REGEX)
    end

    ##
    # Extracts image URLs from text using the centralized regex pattern.
    #
    # @param text [String] The text to extract image URLs from
    # @return [Array<String>] Array of image URLs
    #
    def extract_image_urls(text)
      return [] unless text.is_a?(String)

      text.scan(IMAGE_REGEX).map { |match| match.is_a?(Array) ? match[0] : match }
    end

    ##
    # Extracts attachment URLs from text using the centralized regex pattern.
    #
    # @param text [String] The text to extract attachment URLs from
    # @return [Array<String>] Array of attachment URLs
    #
    def extract_attachment_urls(text)
      return [] unless text.is_a?(String)

      text.scan(ATTACHMENT_REGEX).map { |match| match.is_a?(Array) ? match[0] : match }
    end

    ##
    # Extracts Twitter handles from text using the centralized regex pattern.
    #
    # @param text [String] The text to extract Twitter handles from
    # @return [Array<String>] Array of Twitter handles (without @)
    #
    def extract_twitter_handles(text)
      return [] unless text.is_a?(String)

      text.scan(TWITTER_REGEX).flatten.uniq
    end

    ##
    # Extracts markdown links from text using the centralized regex pattern.
    #
    # @param text [String] The text to extract markdown links from
    # @return [Array<Hash>] Array of hashes with :text and :url keys
    #
    def extract_markdown_links(text)
      return [] unless text.is_a?(String)

      text.scan(MARKDOWN_LINK_REGEX).map { |text, url| { text: text, url: url } }
    end

    ##
    # Extracts hashtags from text using the centralized regex pattern.
    #
    # @param text [String] The text to extract hashtags from
    # @return [Array<String>] Array of hashtags (without #)
    #
    def extract_hashtags(text)
      return [] unless text.is_a?(String)

      text.scan(HASHTAG_REGEX).flatten.uniq
    end

    ##
    # Extracts mentions from text using the centralized regex pattern.
    #
    # @param text [String] The text to extract mentions from
    # @return [Array<String>] Array of mentions (without @)
    #
    def extract_mentions(text)
      return [] unless text.is_a?(String)

      text.scan(MENTION_REGEX).flatten.uniq
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
    require_relative 'constants'
    RichTextExtraction::Constants::VALIDATOR_EXAMPLES.each do |key, meta|
      next unless meta[:regex] && !%i[isbn vin issn iban luhn url].include?(key)

      method_name = "extract_#{key.to_s.pluralize}"
      regex_const = meta[:regex]
      define_method(method_name) do |text|
        return [] unless text.is_a?(String)

        regex = RichTextExtraction::ExtractionPatterns.const_get(regex_const)
        text.scan(regex)
      end
    end
  end
end
