# frozen_string_literal: true

require 'digest'

# Shared controller concern for validator endpoints
# Provides common validation logic and API responses for both main and dummy controllers
module RichTextExtraction
  module Concerns
    module ValidatorsControllerConcern
      extend ActiveSupport::Concern

      included do
        before_action :set_cors_headers
        before_action :check_rate_limit
      end

      # API loop detection constants
      API_LOOP_PREFIX = 'api_validator_loop'
      API_MAX_ATTEMPTS = 5
      API_LOOP_TTL = 300 # 5 minutes

      def index
        validators = RichTextExtraction::ValidatorAPI.list
        fields = params[:fields]&.split(',')&.map(&:strip)

        validators = validators.slice(*fields) if fields&.any?

        render json: validators
      end

      def show
        symbol = params[:id]&.to_sym
        entry = RichTextExtraction::ValidatorAPI.metadata(symbol)

        if entry
          render json: entry
        else
          render json: { error: 'Validator not found' }, status: :not_found
        end
      end

      def examples
        symbol = params[:id]&.to_sym
        entry = RichTextExtraction::ValidatorAPI.metadata(symbol)

        if entry
          render json: { examples: entry[:examples] }
        else
          render json: { error: 'Validator not found' }, status: :not_found
        end
      end

      def regex
        symbol = params[:id]&.to_sym
        regex_pattern = RichTextExtraction::ValidatorAPI.regex(symbol)

        if regex_pattern
          render json: { regex: regex_pattern }
        else
          render json: { error: 'Validator not found' }, status: :not_found
        end
      end

      def validate
        symbol = params[:id]&.to_sym
        value = params[:value]

        # Return error if no value provided
        return render json: { error: 'Value is required' }, status: :bad_request if value.blank?

        # Check for potential infinite loop at API level
        if api_loop_detected?(symbol, value)
          return render json: { error: 'API validation loop detected - possible infinite recursion' },
                        status: :too_many_requests
        end

        # Increment API loop counter
        increment_api_loop_counter(symbol, value)

        # Try to get cached result first
        cache_key = api_cache_key(symbol, value)
        cached_result = Rails.cache.read(cache_key)
        if cached_result
          decrement_api_loop_counter(symbol, value)
          return render json: cached_result
        end

        # Perform validation and render response
        result = perform_validation(symbol, value)
        render json: result
      end

      def batch_validate
        symbol = params[:id]&.to_sym
        values = params[:values] || []
        entry = RichTextExtraction::ValidatorAPI.metadata(symbol)
        return render json: { error: 'Validator not found' }, status: :not_found unless entry

        # Check for potential infinite loop at API level
        if batch_api_loop_detected?(symbol, values)
          return render json: { error: 'API batch validation loop detected - possible infinite recursion' },
                        status: :too_many_requests
        end

        # Increment API loop counter
        increment_batch_api_loop_counter(symbol, values)

        # Try to get cached result first
        cache_key = batch_api_cache_key(symbol, values)
        cached_result = Rails.cache.read(cache_key)
        if cached_result
          decrement_batch_api_loop_counter(symbol, values)
          return render json: cached_result
        end

        # Perform batch validation and render response
        result = perform_batch_validation(symbol, values, entry)
        render json: result
      end

      private

      def set_cors_headers
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
        response.headers['Access-Control-Max-Age'] = '86400'
      end

      def check_rate_limit
        client_ip = request.remote_ip
        rate_limit_key = "rate_limit:#{client_ip}"
        current_count = Rails.cache.read(rate_limit_key).to_i

        if current_count >= 100 # 100 requests per hour
          render json: { error: 'Rate limit exceeded' }, status: :too_many_requests
          return
        end

        Rails.cache.write(rate_limit_key, current_count + 1, expires_in: 1.hour)
      end

      def api_loop_detected?(symbol, value)
        loop_key = api_loop_key(symbol, value)
        attempts = Rails.cache.read(loop_key).to_i
        attempts >= API_MAX_ATTEMPTS
      end

      def increment_api_loop_counter(symbol, value)
        loop_key = api_loop_key(symbol, value)
        attempts = Rails.cache.read(loop_key).to_i + 1
        Rails.cache.write(loop_key, attempts, expires_in: API_LOOP_TTL)
      end

      def decrement_api_loop_counter(symbol, value)
        loop_key = api_loop_key(symbol, value)
        attempts = Rails.cache.read(loop_key).to_i - 1
        if attempts <= 0
          Rails.cache.delete(loop_key)
        else
          Rails.cache.write(loop_key, attempts, expires_in: API_LOOP_TTL)
        end
      end

      def api_cache_key(symbol, value)
        "api_validator_result:#{symbol}:#{Digest::SHA256.hexdigest(value.to_s)}"
      end

      def api_loop_key(symbol, value)
        "#{API_LOOP_PREFIX}:#{symbol}:#{Digest::SHA256.hexdigest(value.to_s)}"
      end

      def batch_api_loop_detected?(symbol, values)
        values.each do |value|
          return true if api_loop_detected?(symbol, value)
        end
        false
      end

      def increment_batch_api_loop_counter(symbol, values)
        values.each do |value|
          increment_api_loop_counter(symbol, value)
        end
      end

      def decrement_batch_api_loop_counter(symbol, values)
        values.each do |value|
          decrement_api_loop_counter(symbol, value)
        end
      end

      def batch_api_cache_key(symbol, values)
        values_hash = Digest::SHA256.hexdigest(values.sort.join('|'))
        "api_batch_validator_result:#{symbol}:#{values_hash}"
      end

      def perform_validation(symbol, value)
        # Perform validation
        result = RichTextExtraction::ValidatorAPI.validate(symbol, value)
        entry = RichTextExtraction::ValidatorAPI.metadata(symbol)
        return render json: { error: 'Validator not found' }, status: :not_found unless entry

        # Prepare response
        jsonld = result[:valid] ? JSON.parse(RichTextExtraction::Constants.to_jsonld(symbol, value) || '{}') : nil
        response_data = {
          valid: result[:valid],
          errors: result[:errors],
          jsonld: jsonld,
          metadata: entry
        }

        # Cache the result
        Rails.cache.write(api_cache_key(symbol, value), response_data, expires_in: 1.hour)
        decrement_api_loop_counter(symbol, value)

        response_data
      end

      def perform_batch_validation(symbol, values, entry)
        # Perform batch validation
        results = values.map { |value| RichTextExtraction::ValidatorAPI.validate(symbol, value) }

        # Prepare response
        response_data = {
          results: results,
          metadata: entry
        }

        # Cache the result
        Rails.cache.write(batch_api_cache_key(symbol, values), response_data, expires_in: 1.hour)
        decrement_batch_api_loop_counter(symbol, values)

        response_data
      end
    end
  end
end
