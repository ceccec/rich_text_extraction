# frozen_string_literal: true

module RichTextExtraction
  module MarkdownHelpers
    # Custom renderer for Redcarpet
    class CustomMarkdownRenderer < Redcarpet::Render::HTML
      def link(link, _title, content)
        "<a href='#{link}' target='_blank' rel='noopener'>#{content}</a>"
      end

      def image(link, _title, alt_text)
        "<img src='#{link}' alt='#{alt_text}' class='markdown-image' />"
      end

      def block_code(code, language)
        lang_class = language ? "language-#{language}" : ''
        "<pre><code class='#{lang_class}'>#{ERB::Util.html_escape(code)}</code></pre>"
      end
    end

    # Renders Markdown to HTML using the preferred engine
    def render_markdown_html(text)
      case markdown_engine
      when :redcarpet
        renderer = CustomMarkdownRenderer.new(filter_html: true, hard_wrap: true)
        markdown = Redcarpet::Markdown.new(
          renderer,
          fenced_code_blocks: true,
          autolink: true,
          tables: true,
          strikethrough: true,
          superscript: true,
          underline: true,
          highlight: true,
          quote: true,
          footnotes: true
        )
        markdown.render(text || '')
      when :kramdown
        Kramdown::Document.new(text || '', input: 'GFM').to_html
      when :commonmarker
        CommonMarker.render_html(text || '', :DEFAULT, %i[table strikethrough autolink])
      else
        ActionController::Base.helpers.simple_format(text)
      end
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