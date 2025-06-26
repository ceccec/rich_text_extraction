# frozen_string_literal: true

module RichTextExtraction
  module API
    ##
    # ValidatorsController provides REST API endpoints for validator operations.
    #
    # This controller handles requests for validator metadata, validation,
    # and batch operations with proper error handling and CORS support.
    #
    class ValidatorsController < ::ApplicationController
      include ValidatorsControllerConcern
    end
  end
end
