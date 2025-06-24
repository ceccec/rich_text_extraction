# frozen_string_literal: true

module RichTextExtraction
  ##
  # OpenGraphHelpers provides OpenGraph preview rendering logic for RichTextExtraction.
  # Includes helpers for HTML, Markdown, and text previews.
  #
  # @see RichTextExtraction
  #
  module OpenGraphHelpers
    # rubocop:disable Metrics/MethodLength
    def opengraph_preview(og_data, format: :html)
      title, description, image, url = opengraph_preview_extract_fields(og_data)
      case format
      when :html
        opengraph_html_preview(title, description, image, url)
      when :markdown
        opengraph_markdown_preview(title, description, image, url)
      when :text
        opengraph_text_preview(title, description, url)
      else
        ''
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    def opengraph_preview_extract_fields(og_data)
      [
        og_data['title'] || og_data[:title] || '',
        og_data['description'] || og_data[:description] || '',
        og_data['image'] || og_data[:image],
        og_data['url'] || og_data[:url]
      ]
    end

    def opengraph_html_preview(title, description, image, url)
      html = +''
      html << "<a href='#{url}' target='_blank' rel='noopener'>" if url
      html << "<img src='#{image}' alt='#{title}' style='max-width:200px;'><br>" if image
      html << "<strong>#{title}</strong>" unless title.empty?
      html << '</a>' if url
      html << "<p>#{description}</p>" unless description.empty?
      html
    end

    def opengraph_markdown_preview(title, description, image, url)
      md = +''
      if image && url
        md << "[![](#{image})](#{url})\n"
      elsif image
        md << "![](#{image})\n"
      end
      md << "**#{title}**\n" unless title.empty?
      md << "#{description}\n" unless description.empty?
      md << "[#{url}](#{url})" if url
      md
    end

    def opengraph_text_preview(title, description, url)
      txt = +''
      txt << "#{title}\n" unless title.empty?
      txt << "#{description}\n" unless description.empty?
      txt << "#{url}\n" if url
      txt
    end
  end
end
