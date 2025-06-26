# frozen_string_literal: true

# Configure SimpleCov for coverage reporting - MUST BE FIRST
require 'simplecov'
SimpleCov.start do
  # Don't filter out the lib directory
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/tmp/'
  add_filter '/test/'
  
  # Track the lib directory specifically
  add_group 'Registry', 'lib/rich_text_extraction/registry.rb'
  add_group 'Core', 'lib/rich_text_extraction/core'
  add_group 'Extractors', 'lib/rich_text_extraction/extractors'
  add_group 'Validators', 'lib/rich_text_extraction/validators'
  add_group 'Helpers', 'lib/rich_text_extraction/helpers'
  add_group 'Services', 'lib/rich_text_extraction/services'
  add_group 'Jobs', 'lib/rich_text_extraction/jobs'
  add_group 'Rails', 'lib/rich_text_extraction/rails'
  add_group 'API', 'lib/rich_text_extraction/api'
  add_group 'Cache', 'lib/rich_text_extraction/cache'
  add_group 'Interfaces', 'lib/rich_text_extraction/interfaces'
  add_group 'Testing', 'lib/rich_text_extraction/testing'
  add_group 'Other', 'lib/rich_text_extraction'
  
  # Set minimum coverage threshold
  minimum_coverage 80
  minimum_coverage_by_file 70
  
  # Enable branch coverage
  enable_coverage :branch
end

ENV['RAILS_ENV'] ||= 'test'
ENV['RAILS_ROOT'] ||= File.expand_path('dummy', __dir__)

# Load Rails environment
Dir.chdir(ENV['RAILS_ROOT']) do
  require File.expand_path('config/environment', ENV['RAILS_ROOT'])
end

abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'spec_helper'

# Require support files
Dir[File.join(__dir__, 'support/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # Ensure Rails is properly initialized before any specs run
  config.before(:suite) do
    # Initialize Rails if not already initialized
    if defined?(Rails) && Rails.application && Rails.application.respond_to?(:initialized?) && !Rails.application.initialized?
      Rails.application.initialize!
    end

    # Set up cache if not available
    if defined?(Rails) && Rails.application && !Rails.cache
      Rails.application.config.cache_store = :memory_store
      Rails.application.initialize! if Rails.application.respond_to?(:initialized?) && !Rails.application.initialized?
    end

    # Reload routes if available
    if defined?(Rails) && Rails.application && Rails.application.respond_to?(:reload_routes!)
      Rails.application.reload_routes!
    end
  end

  # Ensure Rails is available for each test group
  config.before(:all) do
    # Re-initialize Rails if needed
    if defined?(Rails) && Rails.application && Rails.application.respond_to?(:initialized?) && !Rails.application.initialized?
      Rails.application.initialize!
    end

    # Ensure cache is available
    if defined?(Rails) && Rails.application && !Rails.cache
      Rails.application.config.cache_store = :memory_store
      Rails.application.initialize! if Rails.application.respond_to?(:initialized?) && !Rails.application.initialized?
    end
  end

  # Ensure Rails.application is available for request specs
  config.before(:each, type: :request) do
    unless defined?(Rails) && Rails.application
      puts 'WARNING: Rails.application is nil, attempting to reinitialize...'
      begin
        Dir.chdir(ENV['RAILS_ROOT']) do
          require File.expand_path('config/environment', ENV['RAILS_ROOT'])
        end
      rescue StandardError => e
        puts "Failed to reinitialize Rails.application: #{e.message}"
      end
    end
  end

  # Ensure routes are available for request specs
  config.before(:each, type: :request) do
    if defined?(Rails) && Rails.application && Rails.application.respond_to?(:routes) && !Rails.application.routes
      puts 'WARNING: Rails.application.routes is nil, attempting to reload routes...'
      begin
        Rails.application.routes_reloader&.reload! if Rails.application.respond_to?(:routes_reloader)
      rescue StandardError => e
        puts "Failed to reload routes: #{e.message}"
      end
    end
  end
end
