# frozen_string_literal: true

# Test for the example controller generated by the install generator.
# Ensures all actions and JSON keys are present and correct.

require 'test_helper'
require 'rails/generators'
require 'rails/generators/test_case'
require 'generators/rich_text_extraction/install/install_generator'
require_relative '../../support/generator_test_helper'

class ControllerGeneratorTest < Rails::Generators::TestCase
  include GeneratorTestHelper
  tests RichTextExtraction::Generators::InstallGenerator
  destination File.expand_path('../../../../tmp', __dir__)
  setup :prepare_destination

  def test_example_controller_created_with_actions
    run_generator
    assert_file 'app/controllers/example_posts_controller.rb', /class ExamplePostsController/
    assert_file 'app/controllers/example_posts_controller.rb', /before_action :set_example_post/
    assert_file 'app/controllers/example_posts_controller.rb', /def show/
    assert_file 'app/controllers/example_posts_controller.rb', /def index/
    assert_file 'app/controllers/example_posts_controller.rb', /def extract_opengraph_for_url/
    %w[post links opengraph social excerpt].each do |key|
      assert_file 'app/controllers/example_posts_controller.rb', /#{key}:/
    end
  end
end
