# frozen_string_literal: true

# Advanced RichTextExtraction Configuration
# This file contains advanced configuration options for RichTextExtraction.
# You can require this file in your initializer for more complex setups.

module <%= app_name %>
  module RichTextExtractionConfig
    # Custom cache key generator
    def self.generate_cache_key(url, options = {})
      "rte:og:#{Digest::MD5.hexdigest(url)}:#{options[:version] || 'v1'}"
    end

    # Custom OpenGraph data processor
    def self.process_opengraph_data(data)
      # Add your custom processing logic here
      data[:processed_at] = Time.current
      data[:source] = '<%= app_name %>'
      data
    end

    # Custom link validator
    def self.valid_link?(url)
      uri = URI.parse(url)
      uri.scheme.in?(%w[http https]) && uri.host.present?
    rescue URI::InvalidURIError
      false
    end

    # Custom excerpt generator
    def self.generate_excerpt(text, length = 300)
      return text if text.length <= length
      
      truncated = text[0...length]
      last_space = truncated.rindex(' ')
      truncated = truncated[0...last_space] if last_space
      "#{truncated}..."
    end
  end
end 