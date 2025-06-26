# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_examples_api'

RSpec.describe 'Validators API (runtime)', type: :request do
  before(:suite) do
    RichTextExtraction.configuration.instance_variable_set(:@config, nil)
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
      RichTextExtraction.configuration.api_rate_limit = { limit: 1, period: 1.second }
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
      RichTextExtraction.configuration.api_rate_limit = { limit: 0, period: 1.minute }
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

RSpec.describe RichTextExtraction::API::ValidatorAPI, type: :unit do
  describe '.validate' do
    it 'prevents infinite loops with loop detection' do
      # Mock the cache to simulate loop detection
      cache = double('cache')
      allow(cache).to receive(:read).and_return(5) # Simulate max attempts reached
      allow(cache).to receive(:write)
      allow(cache).to receive(:delete)

      # Mock Rails.cache without mocking Rails.logger
      allow(RichTextExtraction::API::ValidatorAPI).to receive(:get_cache_store).and_return(cache)

      result = described_class.validate(:isbn, '978-3-16-148410-0', cache: cache)

      expect(result[:valid]).to be false
      expect(result[:errors]).to include('Validation loop detected - possible infinite recursion')
    end

    it 'caches validation results' do
      cache = double('cache')
      cached_result = { valid: true, errors: [] }

      allow(cache).to receive(:read).and_return(cached_result)
      allow(cache).to receive(:write)
      allow(cache).to receive(:delete)

      result = described_class.validate(:isbn, '978-3-16-148410-0', cache: cache)

      expect(result).to eq(cached_result)
    end

    it 'performs normal validation when no loop detected' do
      cache = double('cache')
      allow(cache).to receive(:read).and_return(nil) # No cached result, no loop
      allow(cache).to receive(:write)
      allow(cache).to receive(:delete)

      result = described_class.validate(:isbn, '978-3-16-148410-0', cache: cache)

      expect(result).to have_key(:valid)
      expect(result).to have_key(:errors)
    end
  end

  describe '.batch_validate' do
    it 'validates multiple values without loops' do
      cache = double('cache')
      allow(cache).to receive(:read).and_return(nil)
      allow(cache).to receive(:write)
      allow(cache).to receive(:delete)

      result = described_class.batch_validate(:isbn, ['978-3-16-148410-0', '123'])

      expect(result).to have_key(:valid)
      expect(result).to have_key(:results)
      expect(result[:results]).to be_an(Array)
      expect(result[:results].length).to eq(2)
    end

    it 'returns error for non-array values' do
      result = described_class.batch_validate(:isbn, 'not an array')

      expect(result[:valid]).to be false
      expect(result[:errors]).to include('Values must be an array')
    end
  end
end
