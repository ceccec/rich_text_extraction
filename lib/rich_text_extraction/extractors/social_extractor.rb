# frozen_string_literal: true

# See spec/extractors/social_extractor_spec.rb for tests of this class

module RichTextExtraction
  module Extractors
    # SocialExtractor provides methods for extracting social media content from text.
    # This class focuses on tags, mentions, and social media handles.
    #
    # @example
    #   extractor = SocialExtractor.new
    #   tags = extractor.extract_tags("Hello #welcome #ruby")
    #   mentions = extractor.extract_mentions("Hello @alice @bob")
    #
    class SocialExtractor
      include RichTextExtraction::Core::Constants
      include RichTextExtraction::Extractors::ExtractionPatterns

      def extract(text, options = {})
        {
          mentions: extract_mentions(text),
          hashtags: extract_tags(text)
        }
      end

      # Class method for consistent API
      def self.extract(text, options = {})
        new.extract(text, options)
      end

      def extract_tags(text)
        extract_social_items(text, HASHTAG_REGEX)
      end

      def extract_mentions(text)
        extract_social_items(text, MENTION_REGEX)
      end

      def extract_twitter_handles(text)
        extract_social_items(text, TWITTER_REGEX)
      end

      def extract_instagram_handles(text)
        extract_social_items(text, TWITTER_REGEX)
      end

      def extract_tags_with_context(text, context_length = 50)
        extract_social_items_with_context(text, HASHTAG_REGEX, context_length, :tag)
      end

      def extract_mentions_with_context(text, context_length = 50)
        extract_social_items_with_context(text, MENTION_REGEX, context_length, :mention)
      end

      def valid_hashtag?(tag)
        valid_social_item?(tag)
      end

      def valid_mention?(mention)
        valid_social_item?(mention)
      end

      private

      def extract_social_items(text, regex)
        return [] unless text.is_a?(String)
        text.scan(regex).flatten.uniq
      end

      def extract_social_items_with_context(text, regex, context_length, key_name)
        return [] unless text.is_a?(String)
        text.scan(regex).flatten.uniq.map do |item|
          {
            key_name => item,
            context: extract_context_for_item(text, item, context_length, regex)
          }
        end
      end

      def valid_social_item?(item)
        return false unless item.is_a?(String)
        !item.empty? && item.match?(/^[\w]+$/)
      end

      def extract_context_for_item(text, _item, context_length, regex)
        match = text.match(regex)
        return text unless match
        start_pos = [match.begin(0) - context_length / 2, 0].max
        end_pos = [match.end(0) + context_length / 2, text.length].min
        text[start_pos...end_pos].strip
      end
    end
  end
end
