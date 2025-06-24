class OpenapiController < ApplicationController
  def show
    send_file Rails.root.join('docs/api/openapi.yaml'), type: 'application/yaml', disposition: 'inline'
  end
end 