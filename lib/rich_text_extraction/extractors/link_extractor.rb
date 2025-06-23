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
  module LinkExtractor
    ##
    # Extracts URLs from text and strips trailing punctuation.
    #
    # @param text [String] The text to extract links from
    # @return [Array<String>] Array of URLs
    #
    def extract_links(text)
      URI.extract(text, %w[http https]).map { |url| url.sub(/[.,!?:;]+$/, '') }
    end

    ##
    # Extracts markdown-style links from text.
    #
    # @param text [String] The text to extract markdown links from
    # @return [Array<Hash>] Array of hashes with :text and :url keys
    #
    def extract_markdown_links(text)
      md_link_regex = %r{\[([^\]]+)\]\((https?://[^)]+)\)}
      text.scan(md_link_regex).map { |text, url| { text: text, url: url } }
    end

    ##
    # Extracts image URLs from text.
    #
    # @param text [String] The text to extract image URLs from
    # @return [Array<String>] Array of image URLs
    #
    def extract_image_urls(text)
      image_regex = %r{https?://[^\s]+?\.(jpg|jpeg|png|gif|svg|webp)}
      text.scan(image_regex).map { |match| match.is_a?(Array) ? match[0] : match }
    end

    ##
    # Extracts attachment URLs from text.
    #
    # @param text [String] The text to extract attachment URLs from
    # @return [Array<String>] Array of attachment URLs
    #
    def extract_attachment_urls(text)
      attachment_regex = %r{https?://[\w\-.?,'/\\+&%$#_=:()~]+\.(pdf|docx?|xlsx?|pptx?|txt|csv|zip|rar|7z)}i
      text.scan(attachment_regex).map { |match| match.is_a?(Array) ? match[0] : match }
    end

    ##
    # Validates if a string is a valid URL.
    #
    # @param url [String] The URL to validate
    # @return [Boolean] True if valid URL, false otherwise
    #
    def valid_url?(url)
      uri = URI.parse(url)
      uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
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