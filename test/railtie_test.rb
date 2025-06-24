# frozen_string_literal: true

require 'minitest/autorun'
require 'rails'
require 'rich_text_extraction/railtie'

class DummyApp < Rails::Application; end

class RailtieTest < Minitest::Test
  def test_railtie_loads
    assert DummyApp.initializers.any? { |i| i.name == 'rich_text_extraction.configure' }
    assert DummyApp.initializers.any? { |i| i.name == 'rich_text_extraction.test_hook' }
  end

  def test_custom_cache_options
    DummyApp.config.rich_text_extraction.cache_options = { expires_in: 123 }
    initializer = DummyApp.initializers.find { |i| i.name == 'rich_text_extraction.configure' }
    # Simulate initializer run
    RichTextExtraction.default_cache_options = nil
    initializer.run(DummyApp)
    assert_equal({ expires_in: 123 }, RichTextExtraction.default_cache_options)
  end
end 