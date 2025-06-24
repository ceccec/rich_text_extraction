# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.swagger_root = Rails.root.join('swagger').to_s

  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'RichTextExtraction Validator API',
        version: 'v1',
        description: 'API for validator metadata, schema.org JSON-LD, validation, and examples.'
      },
      servers: [
        { url: 'http://localhost:3000', description: 'Local server' }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: :JWT
          }
        }
      },
      security: [{ bearerAuth: [] }]
    }
  }

  config.swagger_format = :yaml
end
