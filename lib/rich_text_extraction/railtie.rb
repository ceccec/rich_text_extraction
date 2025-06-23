# frozen_string_literal: true

# RichTextExtraction::Railtie integrates the gem with Rails for configuration.
require 'rails/railtie'

module RichTextExtraction
  # Railtie for configuring RichTextExtraction in Rails apps.
  class Railtie < Rails::Railtie
    config.rich_text_extraction = ActiveSupport::OrderedOptions.new

    initializer 'rich_text_extraction.configure' do |app|
      if app.config.rich_text_extraction.cache_options
        RichTextExtraction.default_cache_options = app.config.rich_text_extraction.cache_options
      end
    end
  end
end
