# frozen_string_literal: true

module RichTextExtraction
  class Helper
    def extract_links(text, options = {})
      begin
        RichTextExtraction::Extractors::LinkExtractor.new.extract(text, options)
      rescue => e
        Rails.logger.warn "Failed to extract links: #{e.message}" if defined?(Rails) && Rails.respond_to?(:logger)
        []
      end
    end

    def extract_mentions(text, options = {})
      begin
        mentions = RichTextExtraction::Extractors::SocialExtractor.new.extract_mentions(text)
        mentions.map { |mention| "@#{mention}" }
      rescue => e
        Rails.logger.warn "Failed to extract mentions: #{e.message}" if defined?(Rails) && Rails.respond_to?(:logger)
        []
      end
    end

    def extract_hashtags(text, options = {})
      begin
        hashtags = RichTextExtraction::Extractors::SocialExtractor.new.extract_tags(text)
        hashtags.map { |hashtag| "##{hashtag}" }
      rescue => e
        Rails.logger.warn "Failed to extract hashtags: #{e.message}" if defined?(Rails) && Rails.respond_to?(:logger)
        []
      end
    end

    def extract_social_media(text, options = {})
      begin
        {
          mentions: extract_mentions(text, options),
          hashtags: extract_hashtags(text, options)
        }
      rescue => e
        Rails.logger.warn "Failed to extract social media: #{e.message}" if defined?(Rails) && Rails.respond_to?(:logger)
        { mentions: [], hashtags: [] }
      end
    end

    def extract_rich_text(text, options = {})
      begin
        {
          links: extract_links(text, options),
          mentions: extract_mentions(text, options),
          hashtags: extract_hashtags(text, options)
        }
      rescue => e
        Rails.logger.warn "Failed to extract rich text: #{e.message}" if defined?(Rails) && Rails.respond_to?(:logger)
        { links: [], mentions: [], hashtags: [] }
      end
    end
  end
end 