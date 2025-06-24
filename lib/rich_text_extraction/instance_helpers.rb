# frozen_string_literal: true

module RichTextExtraction
  ##
  # InstanceHelpers provides instance-level extraction and utility methods for rich text content.
  # These are included in RichTextExtraction and available to ActionText::RichText and other consumers.
  #
  # @see RichTextExtraction
  #
  module InstanceHelpers
    include ExtractionPatterns

    # Returns the plain text representation.
    # @return [String]
    def plain_text
      to_plain_text
    end

    # Extracts all links from the plain text.
    # @return [Array<String>]
    def links
      extract_links(plain_text)
    end

    # Extracts all tags from the plain text.
    # @return [Array<String>]
    def tags
      extract_hashtags(plain_text)
    end

    # Extracts all mentions from the plain text.
    # @return [Array<String>]
    def mentions
      extract_mentions(plain_text)
    end

    # Extracts all emails from the plain text.
    # @return [Array<String>]
    def emails
      extract_emails(plain_text)
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

    # Extracts all phone numbers from the plain text.
    # @return [Array<String>]
    def phone_numbers
      extract_phone_numbers(plain_text)
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

    # Extracts all Twitter handles from the plain text.
    # @return [Array<String>]
    def twitter_handles
      extract_twitter_handles(plain_text)
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
