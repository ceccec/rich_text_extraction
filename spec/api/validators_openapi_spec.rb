# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Validators API', type: :request do
  path '/validators' do
    get 'List all validators' do
      tags 'Validators'
      parameter name: :fields, in: :query, type: :string, description: 'Comma-separated list of fields to include in the response (e.g., "symbol,description,regex")', example: 'symbol,description,regex'
      produces 'application/json'
      response '200', 'validators listed' do
        schema type: :array, items: {
          type: :object,
          properties: {
            symbol: { type: :string, description: 'Validator symbol (e.g., "isbn")', example: 'isbn' },
            schema_type: { type: :string, description: 'Schema.org type (e.g., "Book")', example: 'Book' },
            schema_property: { type: :string, description: 'Schema.org property (e.g., "isbn")', example: 'isbn' },
            description: { type: :string, description: 'Human-readable description of the validator', example: 'Validates ISBN-10 and ISBN-13 codes.' },
            regex: { type: :string, description: 'Validation regex (if pattern-based)', example: '^\\d{13}$' },
            valid: { type: :array, items: { type: :string }, description: 'Valid example values', example: ['978-3-16-148410-0'] },
            invalid: { type: :array, items: { type: :string }, description: 'Invalid example values', example: ['123'] }
          }
        }
        run_test!
      end
    end
  end

  path '/validators/fields' do
    get 'List all available fields' do
      tags 'Validators'
      produces 'application/json'
      response '200', 'fields listed' do
        schema type: :object, properties: { fields: { type: :array, items: { type: :string } } }
        run_test!
      end
    end
  end

  path '/validators/{id}' do
    get 'Get metadata for a validator' do
      tags 'Validators'
      parameter name: :id, in: :path, type: :string, required: true, description: 'Validator symbol (e.g., "isbn")', example: 'isbn'
      parameter name: :fields, in: :query, type: :string, description: 'Comma-separated list of fields to include', example: 'symbol,description,regex'
      produces 'application/json'
      response '200', 'validator found' do
        schema type: :object,
          properties: {
            symbol: { type: :string, description: 'Validator symbol (e.g., "isbn")', example: 'isbn' },
            schema_type: { type: :string, description: 'Schema.org type (e.g., "Book")', example: 'Book' },
            schema_property: { type: :string, description: 'Schema.org property (e.g., "isbn")', example: 'isbn' },
            description: { type: :string, description: 'Human-readable description of the validator', example: 'Validates ISBN-10 and ISBN-13 codes.' },
            regex: { type: :string, description: 'Validation regex (if pattern-based)', example: '^\\d{13}$' },
            valid: { type: :array, items: { type: :string }, description: 'Valid example values', example: ['978-3-16-148410-0'] },
            invalid: { type: :array, items: { type: :string }, description: 'Invalid example values', example: ['123'] }
          }
        run_test!
      end
      response '404', 'not found' do
        run_test!
      end
    end
  end

  path '/validators/{id}/jsonld' do
    get 'Get schema.org JSON-LD for a value' do
      tags 'Validators'
      parameter name: :id, in: :path, type: :string, required: true
      parameter name: :value, in: :query, type: :string, required: true
      produces 'application/json'
      response '200', 'jsonld returned' do
        schema type: :object
        run_test!
      end
      response '404', 'not found' do
        run_test!
      end
    end
  end

  path '/validators/{id}/examples' do
    get 'Get valid/invalid examples for a validator' do
      tags 'Validators'
      parameter name: :id, in: :path, type: :string, required: true
      produces 'application/json'
      response '200', 'examples returned' do
        schema type: :object, properties: {
          valid: { type: :array, items: { type: :string } },
          invalid: { type: :array, items: { type: :string } }
        }
        run_test!
      end
      response '404', 'not found' do
        run_test!
      end
    end
  end

  path '/validators/{id}/regex' do
    get 'Get regex for a validator' do
      tags 'Validators'
      parameter name: :id, in: :path, type: :string, required: true
      produces 'application/json'
      response '200', 'regex returned' do
        schema type: :object, properties: { regex: { type: :string } }
        run_test!
      end
      response '404', 'not found' do
        run_test!
      end
    end
  end

  path '/validators/{id}/validate' do
    post 'Validate a value' do
      tags 'Validators'
      parameter name: :id, in: :path, type: :string, required: true, description: 'Validator symbol (e.g., "isbn")', example: 'isbn'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: { value: { type: :string, description: 'Value to validate', example: '978-3-16-148410-0' } },
        required: ['value']
      }
      response '200', 'validation result' do
        schema type: :object, properties: {
          valid: { type: :boolean, description: 'Whether the value is valid', example: true },
          errors: { type: :array, items: { type: :string }, description: 'Validation error messages', example: [] },
          jsonld: { type: :object, description: 'Schema.org JSON-LD representation (if available)' }
        }
        run_test!
      end
      response '404', 'not found' do
        run_test!
      end
    end
  end

  path '/validators/{id}/batch_validate' do
    post 'Batch validate values' do
      tags 'Validators'
      parameter name: :id, in: :path, type: :string, required: true, description: 'Validator symbol (e.g., "isbn")', example: 'isbn'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: { values: { type: :array, items: { type: :string }, description: 'Array of values to validate', example: ['978-3-16-148410-0', '123'] } },
        required: ['values']
      }
      response '200', 'batch validation result' do
        schema type: :array, items: {
          type: :object,
          properties: {
            value: { type: :string, description: 'Input value', example: '978-3-16-148410-0' },
            valid: { type: :boolean, description: 'Whether the value is valid', example: true },
            errors: { type: :array, items: { type: :string }, description: 'Validation error messages', example: [] },
            jsonld: { type: :object, description: 'Schema.org JSON-LD representation (if available)' }
          }
        }
        run_test!
      end
      response '404', 'not found' do
        run_test!
      end
    end
  end
end
