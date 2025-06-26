# frozen_string_literal: true

module RichTextExtraction
  module Rails
    if defined?(::Rails)
      ##
      # Engine provides Rails engine functionality for RichTextExtraction.
      #
      # This class defines the Rails engine and its configuration.
      #
      class Engine < ::Rails::Engine
        isolate_namespace RichTextExtraction
        # Engine configuration
      end
    end
  end
end
