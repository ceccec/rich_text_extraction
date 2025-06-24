# frozen_string_literal: true

begin
  require 'rails/generators'
rescue LoadError
  puts 'Rails is required for the RichTextExtraction install generator'
  puts "Please add 'rails' to your Gemfile and run 'bundle install'"
  exit 1
end

module RichTextExtraction
  module Generators
    # Generator for installing RichTextExtraction in Rails applications
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Install RichTextExtraction configuration and initializers'

      def create_initializer
        template 'initializer.rb', 'config/initializers/rich_text_extraction.rb'
      end

      def create_configuration
        template 'configuration.rb', 'config/rich_text_extraction.rb'
      end

      def create_example_model
        template 'example_model.rb', 'app/models/example_post.rb'
      end

      def create_example_controller
        template 'example_controller.rb', 'app/controllers/example_posts_controller.rb'
      end

      def create_example_view
        template 'example_view.html.erb', 'app/views/example_posts/show.html.erb'
      end

      def create_example_job
        template 'example_job.rb', 'app/jobs/process_links_job.rb'
      end

      def add_routes
        route 'resources :example_posts, only: [:show]'
      end

      def show_readme
        readme 'README'
      end

      private

      def app_name
        Rails.application.class.module_parent_name
      rescue StandardError
        'YourApp'
      end

      def rails_version
        Rails.version
      rescue StandardError
        '6.0'
      end
    end
  end
end
