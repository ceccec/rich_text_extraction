# frozen_string_literal: true

module RichTextExtraction
  module Helpers
    ##
    # MarkdownHelpers provides Markdown rendering and processing functionality.
    #
    # This module includes methods for rendering Markdown to HTML, extracting
    # Markdown elements, and processing Markdown content.
    #
    module MarkdownHelpers
      # Custom renderer for Redcarpet (single source of truth for all markdown rendering)
      # Use this class everywhere Redcarpet is used in the gem.
      class CustomMarkdownRenderer < Redcarpet::Render::HTML
        # Renders links with security attributes.
        def link(link, _title, content)
          "<a href=\"#{link}\" target=\"_blank\" rel=\"noopener noreferrer\">#{content}</a>"
        end

        # Renders images with proper attributes.
        def image(link, _title, alt_text)
          "<img src=\"#{link}\" alt=\"#{alt_text}\" class=\"markdown-image\" loading=\"lazy\" />"
        end

        # Renders code blocks with syntax highlighting support.
        def block_code(code, language)
          lang_class = language ? "language-#{language}" : ''
          "<pre><code class=\"#{lang_class}\">#{ERB::Util.html_escape(code)}</code></pre>"
        end
      end

      # Renders Markdown to HTML using the preferred engine
      def self.render_markdown_html(text)
        if defined?(Redcarpet)
          render_with_redcarpet(text)
        elsif defined?(Kramdown)
          render_with_kramdown(text)
        elsif defined?(CommonMarker)
          render_with_commonmarker(text)
        else
          render_with_action_controller(text)
        end
      end

      def self.render_with_redcarpet(text)
        renderer = CustomMarkdownRenderer.new(filter_html: true, hard_wrap: true)
        markdown = Redcarpet::Markdown.new(renderer, { fenced_code_blocks: true, autolink: true, tables: true })
        markdown.render(text)
      end

      def self.render_with_kramdown(text)
        Kramdown::Document.new(text || '', input: 'GFM').to_html
      end

      def self.render_with_commonmarker(text)
        CommonMarker.render_html(text || '', :DEFAULT, %i[table strikethrough autolink])
      end

      def self.render_with_action_controller(text)
        ActionController::Base.helpers.simple_format(text)
      end

      private

      def markdown_engine
        return :redcarpet if defined?(Redcarpet)
        return :kramdown if defined?(Kramdown)
        return :commonmarker if defined?(CommonMarker)

        :simple_format
      end
    end
  end
end
