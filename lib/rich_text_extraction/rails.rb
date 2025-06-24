# frozen_string_literal: true

# Rails integration for RichTextExtraction
require_relative 'railtie'
require_relative 'helpers'
require_relative 'extracts_rich_text'

# Load generators for Rails applications
require_relative '../generators/rich_text_extraction/install/install_generator' if defined?(Rails::Generators)
