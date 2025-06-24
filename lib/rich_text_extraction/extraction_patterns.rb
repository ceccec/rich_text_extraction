# frozen_string_literal: true

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
    # Extracts dates from text using the centralized regex pattern.
    #
    # @param text [String] The text to extract dates from
    # @return [Array<String>] Array of dates
    #
    def extract_dates(text)
      return [] unless text.is_a?(String)

      text.scan(DATE_REGEX)
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
  end
end
