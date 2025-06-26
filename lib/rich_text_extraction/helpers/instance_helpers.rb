# frozen_string_literal: true

module RichTextExtraction
  module Helpers
    ##
    # InstanceHelpers provides instance-level extraction and utility methods for rich text content.
    # These are included in RichTextExtraction and available to ActionText::RichText and other consumers.
    #
    # @see RichTextExtraction
    #
    module InstanceHelpers
      include RichTextExtraction::Extractors::ExtractionPatterns

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
          RichTextExtraction.extract(plain_text, extractor_key)
        end
      end

      # Returns the plain text representation.
      # @return [String]
      def plain_text
        to_plain_text
      end

      # Returns a truncated excerpt of the plain text.
      # @param length [Integer]
      # @return [String]
      def excerpt(length = DEFAULT_EXCERPT_LENGTH)
        create_excerpt(plain_text, length)
      end

      # Extracts all attachment URLs from the plain text.
      # @return [Array<String>]
      def attachments
        extract_attachment_urls(plain_text)
      end

      # Extracts all Markdown links from the plain text.
      # @return [Array<Hash>]
      def markdown_links
        extract_markdown_links(plain_text)
      end

      # Extracts all image URLs from the plain text.
      # @return [Array<String>]
      def image_urls
        extract_image_urls(plain_text)
      end

      # Returns link objects, optionally with OpenGraph data.
      # @param with_opengraph [Boolean]
      # @param cache [Hash, Symbol, nil]
      # @param cache_options [Hash]
      # @return [Array<Hash>]
      def link_objects(with_opengraph: false, cache: nil, cache_options: {})
        if with_opengraph
          extract_links(plain_text).map do |url|
            { url: url, opengraph: extract_opengraph(url, cache: cache, cache_options: cache_options) }
          end
        else
          extract_links(plain_text).map { |url| { url: url } }
        end
      end
    end
  end
end
