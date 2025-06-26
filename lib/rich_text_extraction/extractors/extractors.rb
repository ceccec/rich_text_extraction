# frozen_string_literal: true

require_relative 'extraction_helpers'

module RichTextExtraction
  module Extractors
    ##
    # Extractor provides an object-oriented interface for extracting links, mentions, tags, and OpenGraph data from text.
    #
    # @see RichTextExtraction::ExtractionHelpers
    # @see RichTextExtraction
    #
    class Extractor
      include RichTextExtraction::Extractors::ExtractionHelpers
      attr_reader :text

      # Config for instance extraction methods: method => extractor key
      INSTANCE_EXTRACTION_METHODS = {
        links: :links,
        tags: :hashtags,
        mentions: :mentions,
        emails: :emails,
        attachments: :attachments,
        phone_numbers: :phones,
        dates: :dates,
        markdown_links: :markdown_links,
        image_urls: :images,
        twitter_handles: :twitter_handles
      }.freeze

      INSTANCE_EXTRACTION_METHODS.each do |method_name, extractor_key|
        define_method(method_name) do
          with_error_handling { extract(extractor_key) }
        end
      end

      # Initializes a new Extractor.
      # @param text [String] The text to extract from
      def initialize(text)
        @text = text
      end

      # Returns all links in the text.
      # @return [Array<String>]
      def links
        extract_links
      end

      # Returns all @mentions in the text.
      # @return [Array<String>]
      def mentions
        extract_mentions
      end

      # Returns all #tags in the text.
      # @return [Array<String>]
      def tags
        extract_tags
      end

      # Returns an array of hashes for each link, optionally with OpenGraph data.
      # @param with_opengraph [Boolean]
      # @param cache [Hash, Symbol, nil]
      # @param cache_options [Hash]
      # @return [Array<Hash>]
      def link_objects(with_opengraph: false, cache: nil, cache_options: {})
        if with_opengraph
          links.map do |url|
            { url: url, opengraph: extract_opengraph(url, cache: cache, cache_options: cache_options) }
          end
        else
          links.map { |url| { url: url } }
        end
      end

      # Returns OpenGraph data for all links in the text.
      # @return [Array<Hash>]
      def opengraph_data_for_links
        links.map { |url| { url: url, opengraph: extract_opengraph(url) } }
      end

      # Returns all emails in the text.
      # @return [Array<String>]
      def emails
        extract_emails(text)
      end

      # Returns all attachments in the text.
      # @return [Array<String>]
      def attachments
        extract_attachment_urls(text)
      end

      private

      def extract(type)
        case type
        when :links
          extract_links(text)
        when :hashtags
          extract_tags(text)
        when :mentions
          extract_mentions(text)
        when :emails
          extract_emails(text)
        when :attachments
          extract_attachment_urls(text)
        when :phones
          extract_phones(text)
        when :dates
          extract_dates(text)
        when :markdown_links
          extract_markdown_links(text)
        when :images
          extract_images(text)
        when :twitter_handles
          extract_twitter_handles(text)
        else
          []
        end
      end
    end
  end
end
