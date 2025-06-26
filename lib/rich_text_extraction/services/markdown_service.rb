# rubocop:disable Lint/DuplicateMethods
# frozen_string_literal: true

require 'redcarpet'
require 'erb'

module RichTextExtraction
  module Services
    ##
    # MarkdownService handles markdown rendering with custom options and sanitization.
    # This service encapsulates all markdown-related operations for better separation of concerns.
    #
    # @example
    #   service = MarkdownService.new
    #   html = service.render('**Bold text** [link](https://example.com)')
    #
    # See spec/services/markdown_service_spec.rb for tests of this class
    class MarkdownService
      ##
      # Initialize the Markdown service
      #
      # @param options [Hash] Service options
      # @option options [Boolean] :sanitize_html Whether to sanitize HTML output
      # @option options [Hash] :renderer_options Options for the markdown renderer
      def initialize(options = {})
        @sanitize_html = options.fetch(:sanitize_html, true)
        @renderer_options = options.fetch(:renderer_options, {})
      end

      ##
      # Renders markdown text to HTML with custom renderer and options.
      #
      # @param text [String] The markdown text to render
      # @param options [Hash] Rendering options
      # @option options [Boolean] :sanitize Whether to sanitize HTML output
      # @option options [Hash] :renderer_options Options for the markdown renderer
      # @return [String] Rendered HTML
      #
      def render(text, options = {})
        with_error_handling do
          return '' unless text.is_a?(String)

          sanitize = options.fetch(:sanitize, @sanitize_html)
          renderer_options = options.fetch(:renderer_options, @renderer_options)

          html = render_markdown_to_html(text, renderer_options)
          sanitize ? sanitize_html(html) : html
        end
      end

      private

      attr_reader :sanitize_html, :renderer_options

      ##
      # Render markdown to HTML using the appropriate renderer
      #
      # @param text [String] The markdown text
      # @param options [Hash] Renderer options
      # @return [String] The rendered HTML
      def render_markdown_to_html(text, options)
        renderer = create_markdown_renderer(options)
        renderer.render(text)
      end

      ##
      # Create a markdown renderer with the specified options
      #
      # @param options [Hash] Renderer options
      # @return [Object] The markdown renderer
      def create_markdown_renderer(options)
        if defined?(Redcarpet)
          create_redcarpet_renderer(options)
        elsif defined?(Kramdown)
          create_kramdown_renderer(options)
        elsif defined?(CommonMarker)
          create_commonmarker_renderer(options)
        else
          create_fallback_renderer
        end
      end

      ##
      # Create a Redcarpet renderer
      #
      # @param options [Hash] Renderer options
      # @return [Redcarpet::Markdown] The Redcarpet renderer
      def create_redcarpet_renderer(options)
        Redcarpet::Markdown.new(
          Redcarpet::Render::HTML.new(
            link_attributes: { target: '_blank', rel: 'noopener noreferrer' }
          ),
          redcarpet_extensions(options)
        )
      end

      def redcarpet_extensions(options)
        REDCARPET_DEFAULT_EXTENSIONS.merge(options)
      end

      ##
      # Create a Kramdown renderer
      #
      # @param options [Hash] Renderer options
      # @return [Kramdown::Document] The Kramdown renderer
      def create_kramdown_renderer(options)
        Kramdown::Document.new(text, options)
      end

      ##
      # Create a CommonMarker renderer
      #
      # @param options [Hash] Renderer options
      # @return [CommonMarker::Node] The CommonMarker renderer
      def create_commonmarker_renderer(options)
        CommonMarker.render_html(text, options)
      end

      ##
      # Create a fallback renderer
      #
      # @return [Object] A simple fallback renderer
      def create_fallback_renderer
        Class.new do
          def render(text)
            "<p>#{text}</p>"
          end
        end.new
      end

      def sanitize_html(html)
        return html unless html.is_a?(String)

        html.gsub(%r{<script[^>]*>.*?</script>}mi, '')
            .gsub(%r{<iframe[^>]*>.*?</iframe>}mi, '')
            .gsub(/javascript:/i, '')
            .gsub(/on\w+\s*=/i, '')
      end
    end
  end
end

# Register service in the universal registry
RichTextExtraction::Core::UniversalRegistry.instance.register(:services, :markdown, RichTextExtraction::Services::MarkdownService)

# rubocop:enable Lint/DuplicateMethods
