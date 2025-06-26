# frozen_string_literal: true

require 'uri'

module RichTextExtraction
  module Extractors
    # LinkExtractor provides methods for extracting various types of links from text.
    # This class focuses specifically on link extraction operations.
    #
    # @example
    #   extractor = LinkExtractor.new
    #   links = extractor.extract_links("Visit https://example.com and http://test.com")
    #
    class LinkExtractor
      include RichTextExtraction::Core::Constants
      include RichTextExtraction::Extractors::ExtractionPatterns

      def extract(text, options = {})
        extract_links(text)
      end

      # Class method for consistent API
      def self.extract(text, options = {})
        new.extract(text, options)
      end

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
end
