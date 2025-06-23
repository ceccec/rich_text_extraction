# frozen_string_literal: true

module RichTextExtraction
  ##
  # MarkdownHelpers provides Markdown rendering logic for RichTextExtraction.
  # Supports Redcarpet, Kramdown, and CommonMarker engines.
  #
  # @see RichTextExtraction
  #
  module MarkdownHelpers
    # Custom renderer for Redcarpet
    class CustomMarkdownRenderer < Redcarpet::Render::HTML
      def link(link, _title, content)
        "<a href=\"#{link}\" target=\"_blank\" rel=\"noopener\">#{content}</a>"
      end

      def image(link, _title, alt_text)
        "<img src=\"#{link}\" alt=\"#{alt_text}\" class=\"markdown-image\" />"
      end

      def block_code(code, language)
        lang_class = language ? "language-#{language}" : ''
        "<pre><code class='#{lang_class}'>#{ERB::Util.html_escape(code)}</code></pre>"
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
