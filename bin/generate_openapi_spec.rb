#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require_relative '../lib/rich_text_extraction/core/constants'
require_relative '../lib/rich_text_extraction/extraction_patterns'

# Output file
OPENAPI_PATH = File.expand_path('../docs/api/openapi.yaml', __dir__)

# Helper to resolve regex string
RESOLVE_REGEX = lambda do |symbol|
  entry = RichTextExtraction::Constants::VALIDATOR_EXAMPLES[symbol]
  return nil unless entry && entry[:regex]

  begin
    RichTextExtraction::ExtractionPatterns.const_get(entry[:regex])
  rescue StandardError
    nil
  end
end

# Build OpenAPI spec
openapi = {
  'openapi' => '3.0.1',
  'info' => {
    'title' => 'RichTextExtraction Validator API',
    'version' => 'v1',
    'description' => 'API for validator metadata, schema.org JSON-LD, validation, and examples.'
  },
  'servers' => [
    { 'url' => 'https://example.com', 'description' => 'Production' },
    { 'url' => 'http://localhost:3000', 'description' => 'Local' }
  ],
  'paths' => {},
  'components' => {
    'schemas' => {
      'Validator' => {
        'type' => 'object',
        'properties' => {
          'symbol' => { 'type' => 'string', 'description' => 'Validator symbol' },
          'schema_type' => { 'type' => 'string', 'description' => 'Schema.org type' },
          'schema_property' => { 'type' => 'string', 'description' => 'Schema.org property' },
          'description' => { 'type' => 'string', 'description' => 'Description' },
          'regex' => { 'type' => 'string', 'description' => 'Validation regex (if pattern-based)' },
          'valid' => { 'type' => 'array', 'items' => { 'type' => 'string' }, 'description' => 'Valid examples' },
          'invalid' => { 'type' => 'array', 'items' => { 'type' => 'string' }, 'description' => 'Invalid examples' }
        }
      },
      'ValidationResult' => {
        'type' => 'object',
        'properties' => {
          'valid' => { 'type' => 'boolean' },
          'errors' => { 'type' => 'array', 'items' => { 'type' => 'string' } },
          'jsonld' => { 'type' => 'object', 'nullable' => true }
        }
      }
    }
  }
}

# Paths
openapi['paths']['/validators'] = {
  'get' => {
    'summary' => 'List all validators',
    'tags' => ['Validators'],
    'parameters' => [
      {
        'name' => 'fields', 'in' => 'query', 'schema' => { 'type' => 'string' },
        'description' => 'Comma-separated list of fields to include', 'required' => false
      }
    ],
    'responses' => {
      '200' => {
        'description' => 'validators listed',
        'content' => {
          'application/json' => {
            'schema' => { 'type' => 'array', 'items' => { '$ref' => '#/components/schemas/Validator' } }
          }
        }
      }
    }
  }
}
openapi['paths']['/validators/fields'] = {
  'get' => {
    'summary' => 'List all available fields',
    'tags' => ['Validators'],
    'responses' => {
      '200' => {
        'description' => 'fields listed',
        'content' => {
          'application/json' => {
            'schema' => { 'type' => 'object',
                          'properties' => { 'fields' => { 'type' => 'array', 'items' => { 'type' => 'string' } } } }
          }
        }
      }
    }
  }
}

# Per-validator paths (templated)
openapi['paths']['/validators/{id}'] = {
  'get' => {
    'summary' => 'Get metadata for a validator',
    'tags' => ['Validators'],
    'parameters' => [
      { 'name' => 'id', 'in' => 'path', 'required' => true, 'schema' => { 'type' => 'string' }, 'example' => 'isbn' },
      { 'name' => 'fields', 'in' => 'query', 'schema' => { 'type' => 'string' },
        'description' => 'Comma-separated list of fields to include', 'required' => false }
    ],
    'responses' => {
      '200' => {
        'description' => 'validator found',
        'content' => {
          'application/json' => { 'schema' => { '$ref' => '#/components/schemas/Validator' } }
        }
      },
      '404' => { 'description' => 'not found' }
    }
  }
}
openapi['paths']['/validators/{id}/jsonld'] = {
  'get' => {
    'summary' => 'Get schema.org JSON-LD for a value',
    'tags' => ['Validators'],
    'parameters' => [
      { 'name' => 'id', 'in' => 'path', 'required' => true, 'schema' => { 'type' => 'string' }, 'example' => 'isbn' },
      { 'name' => 'value', 'in' => 'query', 'required' => true, 'schema' => { 'type' => 'string' } }
    ],
    'responses' => {
      '200' => { 'description' => 'jsonld returned',
                 'content' => { 'application/json' => { 'schema' => { 'type' => 'object' } } } },
      '404' => { 'description' => 'not found' }
    }
  }
}
openapi['paths']['/validators/{id}/examples'] = {
  'get' => {
    'summary' => 'Get valid/invalid examples for a validator',
    'tags' => ['Validators'],
    'parameters' => [
      { 'name' => 'id', 'in' => 'path', 'required' => true, 'schema' => { 'type' => 'string' }, 'example' => 'isbn' }
    ],
    'responses' => {
      '200' => {
        'description' => 'examples returned',
        'content' => {
          'application/json' => {
            'schema' => {
              'type' => 'object',
              'properties' => {
                'valid' => { 'type' => 'array', 'items' => { 'type' => 'string' } },
                'invalid' => { 'type' => 'array', 'items' => { 'type' => 'string' } }
              }
            }
          }
        }
      },
      '404' => { 'description' => 'not found' }
    }
  }
}
openapi['paths']['/validators/{id}/regex'] = {
  'get' => {
    'summary' => 'Get regex for a validator',
    'tags' => ['Validators'],
    'parameters' => [
      { 'name' => 'id', 'in' => 'path', 'required' => true, 'schema' => { 'type' => 'string' }, 'example' => 'isbn' }
    ],
    'responses' => {
      '200' => {
        'description' => 'regex returned',
        'content' => {
          'application/json' => {
            'schema' => { 'type' => 'object', 'properties' => { 'regex' => { 'type' => 'string' } } }
          }
        }
      },
      '404' => { 'description' => 'not found' }
    }
  }
}
openapi['paths']['/validators/{id}/validate'] = {
  'post' => {
    'summary' => 'Validate a value',
    'tags' => ['Validators'],
    'parameters' => [
      { 'name' => 'id', 'in' => 'path', 'required' => true, 'schema' => { 'type' => 'string' }, 'example' => 'isbn' }
    ],
    'requestBody' => {
      'required' => true,
      'content' => {
        'application/json' => {
          'schema' => {
            'type' => 'object',
            'properties' => { 'value' => { 'type' => 'string' } },
            'required' => ['value']
          }
        }
      }
    },
    'responses' => {
      '200' => {
        'description' => 'validation result',
        'content' => {
          'application/json' => { 'schema' => { '$ref' => '#/components/schemas/ValidationResult' } }
        }
      },
      '404' => { 'description' => 'not found' }
    }
  }
}
openapi['paths']['/validators/{id}/batch_validate'] = {
  'post' => {
    'summary' => 'Batch validate values',
    'tags' => ['Validators'],
    'parameters' => [
      { 'name' => 'id', 'in' => 'path', 'required' => true, 'schema' => { 'type' => 'string' }, 'example' => 'isbn' }
    ],
    'requestBody' => {
      'required' => true,
      'content' => {
        'application/json' => {
          'schema' => {
            'type' => 'object',
            'properties' => { 'values' => { 'type' => 'array', 'items' => { 'type' => 'string' } } },
            'required' => ['values']
          }
        }
      }
    },
    'responses' => {
      '200' => {
        'description' => 'batch validation result',
        'content' => {
          'application/json' => {
            'schema' => {
              'type' => 'array',
              'items' => { '$ref' => '#/components/schemas/ValidationResult' }
            }
          }
        }
      },
      '404' => { 'description' => 'not found' }
    }
  }
}

# Write file
FileUtils.mkdir_p(File.dirname(OPENAPI_PATH))

banner = "# DO NOT EDIT: This file is auto-generated by bin/generate_openapi_spec.rb. Edit Ruby sources only.\n"
File.write(OPENAPI_PATH, banner + openapi.to_yaml)
puts "OpenAPI spec written to #{OPENAPI_PATH}"
