# frozen_string_literal: true

# Test for the README output by the install generator.
# Ensures the README contains all key sections and instructions.

require 'test_helper'
require 'rails/generators'
require 'rails/generators/test_case'
require 'generators/rich_text_extraction/install/install_generator'
require_relative '../../support/generator_test_helper'

class ReadmeGeneratorTest < Rails::Generators::TestCase
  include GeneratorTestHelper
  tests RichTextExtraction::Generators::InstallGenerator
  destination File.expand_path('../../../../tmp', __dir__)
  setup :prepare_destination

  def test_readme_shown
    output = run_generator
    assert_match /RichTextExtraction Installation Complete/, output
    assert_match /Generated Files/, output
    assert_match /Next Steps/, output
    assert_match /Key Features Demonstrated/, output
    assert_match /Configuration Options/, output
    assert_match /Testing/, output
    assert_match /Documentation/, output
    assert_match /Cleanup/, output
  end
end 