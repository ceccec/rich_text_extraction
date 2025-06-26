# frozen_string_literal: true

require 'bundler/setup'
require 'rspec'

# Automatically require all support files (shared contexts, examples, etc.)
Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

# Configure RSpec
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Include shared contexts and examples in all specs
  config.include_context 'with common test data'
end
