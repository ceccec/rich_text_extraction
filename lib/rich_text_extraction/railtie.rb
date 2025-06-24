# frozen_string_literal: true

# RichTextExtraction::Railtie integrates the gem with Rails for configuration.
require 'rails/railtie'

module RichTextExtraction
  # Railtie for configuring RichTextExtraction in Rails apps.
  class Railtie < Rails::Railtie
    config.rich_text_extraction = ActiveSupport::OrderedOptions.new

    # Allows custom configuration via Rails initializers
    # Example:
    #   Rails.application.config.rich_text_extraction.cache_options = { expires_in: 1.hour }
    initializer 'rich_text_extraction.configure' do |app|
      if app.config.rich_text_extraction.cache_options
        RichTextExtraction.default_cache_options = app.config.rich_text_extraction.cache_options
      end
    end

    # Test hook for Railtie loading
    initializer 'rich_text_extraction.test_hook' do
      # This can be used in tests to assert the Railtie loaded
    end
  end
end
