# frozen_string_literal: true

require 'redcarpet'
require 'erb'

module RichTextExtraction
  ##
  # MarkdownService handles markdown rendering with custom options and sanitization.
  # This service encapsulates all markdown-related operations for better separation of concerns.
  #
  # @example
  #   service = MarkdownService.new
  #   html = service.render('**Bold text** [link](https://example.com)')
  #
  class MarkdownService
    ##
    # Renders markdown text to HTML with custom renderer and options.
    #
    # @param text [String] The markdown text to render
    # @param options [Hash] Rendering options
    # @option options [Boolean] :sanitize Whether to sanitize HTML output (default: true)
    # @option options [Hash] :renderer_options Options for the custom renderer
    # @return [String] Rendered HTML
    #
    def render(text, options = {})
      options = { sanitize: true }.merge(options)
      
      renderer = create_renderer(options[:renderer_options] || {})
      markdown = create_markdown(renderer)
      
      html = markdown.render(text)
      options[:sanitize] ? sanitize_html(html) : html
    end

    ##
    # Creates a custom markdown renderer with specific options.
    #
    # @param options [Hash] Renderer options
    # @return [CustomMarkdownRenderer] Configured renderer instance
    #
    def create_renderer(options = {})
      CustomMarkdownRenderer.new(options)
    end

    ##
    # Creates a markdown processor with the given renderer.
    #
    # @param renderer [CustomMarkdownRenderer] The renderer to use
    # @return [Redcarpet::Markdown] Configured markdown processor
    #
    def create_markdown(renderer)
      Redcarpet::Markdown.new(
        renderer,
        autolink: true,
        tables: true,
        fenced_code_blocks: true,
        strikethrough: true,
        superscript: true,
        underline: true,
        highlight: true,
        quote: true,
        footnotes: true
      )
    end

    private

    def sanitize_html(html)
      # Basic HTML sanitization - you can enhance this with a proper sanitizer
      html.gsub(/<script[^>]*>.*?<\/script>/mi, '')
          .gsub(/<iframe[^>]*>.*?<\/iframe>/mi, '')
          .gsub(/javascript:/i, '')
          .gsub(/on\w+\s*=/i, '')
    end
  end

  ##
  # CustomMarkdownRenderer customizes Redcarpet's HTML rendering for links, images, and code blocks.
  # This renderer adds security features and custom styling.
  #
  class CustomMarkdownRenderer < Redcarpet::Render::HTML
    ##
    # Renders links with security attributes.
    #
    # @param link [String] The URL
    # @param title [String] The link title
    # @param content [String] The link text
    # @return [String] Rendered link HTML
    #
    def link(link, _title, content)
      "<a href=\"#{link}\" target=\"_blank\" rel=\"noopener noreferrer\">#{content}</a>"
    end

    ##
    # Renders images with proper attributes.
    #
    # @param link [String] The image URL
    # @param title [String] The image title
    # @param alt_text [String] The alt text
    # @return [String] Rendered image HTML
    #
    def image(link, _title, alt_text)
      "<img src=\"#{link}\" alt=\"#{alt_text}\" class=\"markdown-image\" loading=\"lazy\" />"
    end

    ##
    # Renders code blocks with syntax highlighting support.
    #
    # @param code [String] The code content
    # @param language [String] The programming language
    # @return [String] Rendered code block HTML
    #
    def block_code(code, language)
      lang_class = language ? "language-#{language}" : ''
      "<pre><code class=\"#{lang_class}\">#{ERB::Util.html_escape(code)}</code></pre>"
    end
  end
end 