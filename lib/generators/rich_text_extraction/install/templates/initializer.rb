# frozen_string_literal: true

# RichTextExtraction Configuration
# This file configures RichTextExtraction for your Rails application.
# See https://github.com/ceccec/rich_text_extraction for documentation.

RichTextExtraction.configure do |config|
  # OpenGraph Configuration
  config.opengraph_timeout = 15.seconds
  config.max_redirects = 5
  config.user_agent = '<%= app_name %>/1.0'
  config.sanitize_html = true

  # Markdown Configuration
  config.markdown_renderer = :redcarpet
  config.markdown_options = {
    hard_wrap: true,
    link_attributes: { target: '_blank', rel: 'noopener noreferrer' }
  }

  # Cache Configuration
  config.cache_enabled = Rails.env.production?
  config.cache_prefix = 'rte'
  config.cache_ttl = 1.hour
  config.cache_compression = true

  # Content Configuration
  config.default_excerpt_length = 300
  config.max_link_count = 50
  config.max_content_length = 10_000

  # Debug Configuration
  config.debug = Rails.env.development?
  config.log_level = Rails.env.development? ? :debug : :info

  # Security Configuration
  config.allowed_protocols = %w[http https]
  config.blocked_domains = []
  config.max_image_size = 5.megabytes
end

# Optional: Configure Rails-specific cache options
# Rails.application.config.rich_text_extraction.cache_options = {
#   expires_in: 1.hour,
#   key_prefix: 'rte'
# }

# === Internationalization (I18n) Support for Validators ===
#
# To customize validator error messages, add a file like config/locales/rich_text_extraction.en.yml:
#
#   en:
#     errors:
#       messages:
#         isbn: "is not a valid ISBN"
#         vin: "is not a valid VIN"
#         issn: "is not a valid ISSN"
#         iban: "is not a valid IBAN"
#         luhn: "is not a valid number (Luhn check failed)"
#         ean13: "is not a valid EAN-13 barcode"
#         upca: "is not a valid UPC-A barcode"
#         uuid: "is not a valid UUID"
#         hex_color: "is not a valid hex color"
#         ip: "is not a valid IPv4 address"
#         mac_address: "is not a valid MAC address"
#         hashtag: "is not a valid hashtag"
#         mention: "is not a valid mention"
#         twitter_handle: "is not a valid Twitter handle"
#         instagram_handle: "is not a valid Instagram handle"
#         url: "is not a valid URL"
#
# Rails will use these messages automatically if present.
#
# To load custom locales, add to your config/application.rb:
#   config.i18n.load_path += Dir[Rails.root.join('config/locales/**/*.yml')]
