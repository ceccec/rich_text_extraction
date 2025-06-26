# frozen_string_literal: true

# OpenAPI documentation controller for API specification
class OpenapiController < ApplicationController
  def show
    send_file Rails.root.join('docs/api/openapi.yaml'), type: 'application/yaml', disposition: 'inline'
  end

  def index
    render json: Rails.application.routes.routes.map(&:path)
  end
end
