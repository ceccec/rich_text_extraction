# frozen_string_literal: true

require 'uri'

module RichTextExtraction
  ##
  # LinkExtractor provides methods for extracting various types of links from text.
  # This module focuses specifically on link extraction operations.
  #
  # @example
  #   include LinkExtractor
  #   links = extract_links("Visit https://example.com and http://test.com")
  #
  # See spec/extractors/link_extractor_spec.rb for tests of this module
  module LinkExtractor
    include Constants

    ##
    # Extracts URLs from text and strips trailing punctuation.
    #
    # @param text [String] The text to extract links from
    # @return [Array<String>] Array of URLs
    #
    def extract_links(text)
      return [] unless text.is_a?(String)

      URI.extract(text, %w[http https]).map { |url| url.sub(/[.,!?:;]+$/, '') }
    end

    ##
    # Extracts markdown-style links from text.
    #
    # @param text [String] The text to extract markdown links from
    # @return [Array<Hash>] Array of hashes with :text and :url keys
    #
    def extract_markdown_links(text)
      return [] unless text.is_a?(String)

      text.scan(MARKDOWN_LINK_REGEX).map { |text, url| { text: text, url: url } }
    end

    ##
    # Extracts image URLs from text.
    #
    # @param text [String] The text to extract image URLs from
    # @return [Array<String>] Array of image URLs
    #
    def extract_image_urls(text)
      return [] unless text.is_a?(String)

      text.scan(IMAGE_REGEX).map { |match| match.is_a?(Array) ? match[0] : match }
    end

    ##
    # Extracts attachment URLs from text.
    #
    # @param text [String] The text to extract attachment URLs from
    # @return [Array<String>] Array of attachment URLs
    #
    def extract_attachment_urls(text)
      return [] unless text.is_a?(String)

      text.scan(ATTACHMENT_REGEX).map { |match| match.is_a?(Array) ? match[0] : match }
    end

    ##
    # Validates if a string is a valid URL.
    #
    # @param url [String] The URL to validate
    # @return [Boolean] True if valid URL, false otherwise
    #
    def valid_url?(url)
      return false unless url.is_a?(String)

      URI::DEFAULT_PARSER.make_regexp(%w[http https]).match?(url)
    rescue URI::InvalidURIError
      false
    end

    ##
    # Normalizes URLs by removing trailing slashes and query parameters.
    #
    # @param url [String] The URL to normalize
    # @return [String] Normalized URL
    #
    def normalize_url(url)
      uri = URI.parse(url)
      uri.fragment = nil
      uri.query = nil
      uri.to_s.chomp('/')
    rescue URI::InvalidURIError
      url
    end
  end
end
