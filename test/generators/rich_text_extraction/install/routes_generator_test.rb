# frozen_string_literal: true

# Test for the routes added by the install generator.
# Ensures the example_posts resource is added to config/routes.rb.

require 'test_helper'
require 'rails/generators'
require 'rails/generators/test_case'
require 'generators/rich_text_extraction/install/install_generator'
require_relative '../../support/generator_test_helper'

class RoutesGeneratorTest < Rails::Generators::TestCase
  include GeneratorTestHelper
  tests RichTextExtraction::Generators::InstallGenerator
  destination File.expand_path('../../../../tmp', __dir__)
  setup :prepare_destination

  def test_routes_added
    run_generator
    assert_file 'config/routes.rb', /resources :example_posts, only: \[:show\]/
  end
end 