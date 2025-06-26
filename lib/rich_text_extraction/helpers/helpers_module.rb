# frozen_string_literal: true

# RichTextExtraction::Helpers provides Rails view helpers for OpenGraph previews.
module RichTextExtraction
  # Helpers for rendering OpenGraph previews in Rails views.
  module Helpers
    ##
    # HelpersModule provides a collection of utility methods for RichTextExtraction.
    #
    # This module contains helper methods that are used across different parts
    # of the gem to provide common functionality.
    #
    module HelpersModule
      extend ActiveSupport::Concern

      # Helper methods for rich text extraction
      def extract_links_from_text(text)
        universal_extract_links(text)
      end

      def extract_mentions_from_text(text)
        universal_extract_mentions(text)
      end

      def extract_hashtags_from_text(text)
        universal_extract_hashtags(text)
      end

      def extract_social_media_from_text(text)
        universal_extract_social_media(text)
      end

      def extract_rich_text_from_text(text)
        universal_extract_rich_text(text)
      end

      # Shared method for extracting OpenGraph data from a URL
      def extract_opengraph_data_from_url(url)
        extractor = RichTextExtraction::Extractor.new(url)
        data = extractor.opengraph_data_for_links.first
        data ? data[:opengraph] : {}
      rescue StandardError => e
        Rails.logger.warn "Failed to extract OpenGraph for #{url}: #{e.message}" if defined?(Rails)
        { error: e.message, url: url }
      end

      # Renders an OpenGraph preview for a URL or OpenGraph data hash.
      # @param url_or_og [String, Hash]
      # @param format [Symbol] :html, :markdown, or :text
      # @return [String]
      def opengraph_preview_for(url_or_og, format: :html)
        og = if url_or_og.is_a?(String)
               extract_opengraph_data_from_url(url_or_og)
             else
               url_or_og
             end

        case format
        when :html
          render_html_preview(og)
        when :markdown
          render_markdown_preview(og)
        when :text
          render_text_preview(og)
        else
          render_html_preview(og)
        end
      end

      private

      def render_html_preview(og)
        title = og[:title] || og['title'] || 'No title'
        url = og[:url] || og['url'] || '#'
        description = og[:description] || og['description'] || 'No description'
        image = og[:image] || og['image']
        site_name = og[:site_name] || og['site_name']

        html = "<div class='opengraph-preview'>\n  <h3>#{title}</h3>\n  <p>#{description}</p>\n  <a href='#{url}'>#{url}</a>"
        html += "\n  <img src='#{image}' alt='OpenGraph image' />" if image
        html += "\n  <div class='site-name'>#{site_name}</div>" if site_name
        html += "\n</div>"
        html
      end

      def render_markdown_preview(og)
        title = og[:title] || og['title'] || 'No title'
        url = og[:url] || og['url'] || '#'
        description = og[:description] || og['description'] || 'No description'
        image = og[:image] || og['image']
        site_name = og[:site_name] || og['site_name']

        md = "## #{title}\n\n#{description}\n\n[#{url}](#{url})"
        md += "\n\n![OpenGraph image](#{image})" if image
        md += "\n\n**Site:** #{site_name}" if site_name
        md
      end

      def render_text_preview(og)
        title = og[:title] || og['title'] || 'No title'
        url = og[:url] || og['url'] || '#'
        description = og[:description] || og['description'] || 'No description'
        image = og[:image] || og['image']
        site_name = og[:site_name] || og['site_name']

        txt = "#{title}\n\n#{description}\n\n#{url}"
        txt += "\n\nImage: #{image}" if image
        txt += "\nSite: #{site_name}" if site_name
        txt
      end

      def safe_render(&block)
        with_error_handling { yield }
      end

      # Delegate to universal helper methods
      def universal_extract_links(text)
        RichTextExtraction::Helper.new.extract_links(text)
      end

      def universal_extract_mentions(text)
        RichTextExtraction::Helper.new.extract_mentions(text)
      end

      def universal_extract_hashtags(text)
        RichTextExtraction::Helper.new.extract_hashtags(text)
      end

      def universal_extract_social_media(text)
        RichTextExtraction::Helper.new.extract_social_media(text)
      end

      def universal_extract_rich_text(text)
        RichTextExtraction::Helper.new.extract_rich_text(text)
      end
    end
  end
end

# Auto-include helpers in ActionView::Base if Rails is loaded
# @!parse
#   ActionView::Base.include RichTextExtraction::Helpers if defined?(Rails) && defined?(ActionView::Base)
if defined?(Rails) && defined?(ActionView::Base)
  ActiveSupport.on_load(:action_view) { include RichTextExtraction::Helpers }
end
