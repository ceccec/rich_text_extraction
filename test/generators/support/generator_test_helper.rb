# frozen_string_literal: true

# Shared setup for Rails generator tests.
module GeneratorTestHelper
  def self.included(base)
    base.destination File.expand_path('../../../tmp', __dir__)
    base.setup :prepare_destination
  end
end 