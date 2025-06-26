# frozen_string_literal: true

# Load the RichTextExtraction gem
require 'rich_text_extraction'

# Configure RichTextExtraction for the dummy application
RichTextExtraction.configure do |config|
  # Allow CORS from specific origins or all
  config.api_cors_origins = ['https://myfrontend.com', 'https://admin.myapp.com']
  # Set rate limit: 60 requests per minute
  config.api_rate_limit = { limit: 60, period: 1.minute }
  # Custom CORS headers and methods
  config.api_cors_headers = %w[Origin Content-Type Accept Authorization X-Custom-Header]
  config.api_cors_methods = %w[GET POST OPTIONS PUT]
  # Per-user rate limit: 100/hour
  config.api_rate_limit_per_user = { limit: 100, period: 1.hour }
  # Per-endpoint rate limit
  config.api_rate_limit_per_endpoint = {
    '/validators/validate' => { limit: 10, period: 1.minute }
  }
end
