# frozen_string_literal: true

# Test for the example view generated by the install generator.
# Ensures all sections and content are present and correct.

require 'test_helper'
require 'rails/generators'
require 'rails/generators/test_case'
require 'generators/rich_text_extraction/install/install_generator'
require_relative '../../support/generator_test_helper'

class ViewGeneratorTest < Rails::Generators::TestCase
  include GeneratorTestHelper
  tests RichTextExtraction::Generators::InstallGenerator
  destination File.expand_path('../../../../tmp', __dir__)
  setup :prepare_destination

  def test_example_view_created_with_sections
    run_generator
    assert_file 'app/views/example_posts/show.html.erb', /opengraph_preview_for/
    assert_file 'app/views/example_posts/show.html.erb', /@links/
    assert_file 'app/views/example_posts/show.html.erb', /@opengraph_data/
    assert_file 'app/views/example_posts/show.html.erb', /@social_content/
    %w[Links Found Link Previews Tags Mentions Email Addresses Phone Numbers processing-status].each do |section|
      assert_file 'app/views/example_posts/show.html.erb', /#{section}/
    end
  end
end
