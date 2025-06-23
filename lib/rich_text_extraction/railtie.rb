require 'rails/railtie'

module RichTextExtraction
  class Railtie < Rails::Railtie
    config.rich_text_extraction = ActiveSupport::OrderedOptions.new

    initializer "rich_text_extraction.configure" do |app|
      RichTextExtraction.default_cache_options = app.config.rich_text_extraction.cache_options if app.config.rich_text_extraction.cache_options
    end
  end
end 