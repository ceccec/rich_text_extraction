# frozen_string_literal: true

require 'digest'

module RichTextExtraction
  class ValidatorsController < ::ApplicationController
    include Concerns::ValidatorsControllerConcern
  end
end
