# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_examples_api'

RSpec.describe 'Validators API (runtime)', type: :request do
  before(:suite) do
    RichTextExtraction.instance_variable_set(:@config, nil)
  end

  describe 'CORS' do
    include_examples 'CORS headers', '/validators'
    include_examples 'CORS headers', '/validators/fields'
  end

  describe 'Rate limiting' do
    include_examples 'rate limiting', '/validators', { limit: 2, period: 1.minute }

    it 'resets rate limit after period' do
      Redis.new
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('1.2.3.4')
      RichTextExtraction.config.api_rate_limit = { limit: 1, period: 1.second }
      get '/validators'
      expect(response.status).to eq(200)
      get '/validators'
      expect(response.status).to eq(429)
      sleep 1.2
      get '/validators'
      expect(response.status).to eq(200)
    end
  end

  describe 'Custom error responses' do
    it 'returns custom error JSON for rate limit exceeded' do
      RichTextExtraction.config.api_rate_limit = { limit: 0, period: 1.minute }
      get '/validators'
      expect(response.status).to eq(429)
      expect(response.parsed_body).to include('error' => 'Rate limit exceeded')
    end
  end

  describe 'CORS preflight OPTIONS' do
    it 'responds to OPTIONS with correct CORS headers' do
      options '/validators', headers: { 'Origin' => 'https://myfrontend.com', 'Access-Control-Request-Method' => 'GET' }
      expect(response.status).to eq(204).or eq(200)
      expect(response.headers['Access-Control-Allow-Origin']).to be_present
      expect(response.headers['Access-Control-Allow-Methods']).to include('GET')
      expect(response.headers['Access-Control-Allow-Headers']).to include('Content-Type')
    end
  end
end
