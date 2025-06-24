# frozen_string_literal: true

module RichTextExtraction
  class ValidatorsController < ApplicationController
    include ActionController::MimeResponds
    before_action :set_cors_headers
    before_action :check_rate_limit, except: [:options]

    # Use Rails.cache and config cache_options for request->response caching
    delegate :cache, to: :Rails

    # === DRY, Doc-Driven API Controller ===
    # All validator metadata, examples, and validation logic are sourced from
    # RichTextExtraction::Constants::VALIDATOR_EXAMPLES (the single source of truth).
    # Adding or updating a validator only requires editing VALIDATOR_EXAMPLES.
    # All endpoints, docs, and tests are auto-generated from this source.

    def cache_options
      config = RichTextExtraction.respond_to?(:configuration) ? RichTextExtraction.configuration : nil
      config.respond_to?(:cache_options) ? config.cache_options : { expires_in: 1.hour }
    end

    def options
      set_cors_headers
      head :no_content
    end

    def index
      fields = params[:fields]&.split(',')
      validators = RichTextExtraction::Constants::VALIDATOR_EXAMPLES.map do |symbol, meta|
        entry = meta.dup
        entry[:symbol] = symbol
        fields ? entry.slice(*fields.map(&:to_sym)) : entry
      end
      render json: validators
    end

    def fields
      render json: { fields: %i[schema_type schema_property description regex valid invalid] }
    end

    def show
      symbol = params[:id]&.to_sym
      entry = RichTextExtraction::ValidatorAPI.metadata(symbol)
      return render json: { error: 'Validator not found' }, status: :not_found unless entry

      render json: entry.merge(symbol: symbol)
    end

    def jsonld
      symbol = params[:id]&.to_sym
      value = params[:value]
      entry = RichTextExtraction::ValidatorAPI.metadata(symbol)
      return render json: { error: 'Validator not found' }, status: :not_found unless entry

      jsonld = RichTextExtraction::Constants.to_jsonld(symbol, value)
      render json: JSON.parse(jsonld)
    end

    def examples
      symbol = params[:id]&.to_sym
      ex = RichTextExtraction::ValidatorAPI.examples(symbol)
      return render json: { error: 'Validator not found' }, status: :not_found if ex[:valid].nil? && ex[:invalid].nil?

      render json: ex
    end

    def regex
      symbol = params[:id]&.to_sym
      regex = RichTextExtraction::ValidatorAPI.regex(symbol)
      entry = RichTextExtraction::ValidatorAPI.metadata(symbol)
      return render json: { error: 'Validator not found' }, status: :not_found unless entry

      render json: { regex: regex }
    end

    # All validation requests are cached by default using Rails.cache and config cache_options
    def validate
      symbol = params[:id]&.to_sym
      value = params[:value] || (params[:validator] && params[:validator][:value])
      result = RichTextExtraction::ValidatorAPI.validate(symbol, value, cache: cache, cache_options: cache_options)
      entry = RichTextExtraction::ValidatorAPI.metadata(symbol)
      return render json: { error: 'Validator not found' }, status: :not_found unless entry

      jsonld = result[:valid] ? JSON.parse(RichTextExtraction::Constants.to_jsonld(symbol, value) || '{}') : nil
      render json: { valid: result[:valid], errors: result[:errors], jsonld: jsonld }
    end

    def batch_validate
      symbol = params[:id]&.to_sym
      values = params[:values] || []
      entry = RichTextExtraction::ValidatorAPI.metadata(symbol)
      return render json: { error: 'Validator not found' }, status: :not_found unless entry

      results = RichTextExtraction::ValidatorAPI.batch_validate(symbol, values, cache: cache,
                                                                                cache_options: cache_options)
      results.each_with_index do |result, idx|
        result[:jsonld] =
          result[:valid] ? JSON.parse(RichTextExtraction::Constants.to_jsonld(symbol, values[idx]) || '{}') : nil
      end
      render json: results
    end

    private

    def set_cors_headers
      origins = Array(RichTextExtraction.config.api_cors_origins)
      headers['Access-Control-Allow-Origin'] = origins.include?('*') ? '*' : origins.join(', ')
      headers['Access-Control-Allow-Methods'] = Array(RichTextExtraction.config.api_cors_methods).join(', ')
      headers['Access-Control-Allow-Headers'] = Array(RichTextExtraction.config.api_cors_headers).join(', ')
    end

    def check_rate_limit
      return if request.method == 'OPTIONS'

      config = RichTextExtraction.config.api_rate_limit
      per_user = RichTextExtraction.config.api_rate_limit_per_user
      per_endpoint = RichTextExtraction.config.api_rate_limit_per_endpoint&.dig(request.path)
      limit_config = per_endpoint || per_user || config
      return unless limit_config

      cache = Rails.cache
      key = "rate-limit:#{rate_limit_identifier}:#{request.path}"
      count = cache.read(key).to_i + 1
      cache.write(key, count, expires_in: limit_config[:period])
      return unless count >= limit_config[:limit]

      render json: { error: 'Rate limit exceeded' }, status: :too_many_requests
    end

    def rate_limit_identifier
      if respond_to?(:current_user) && current_user&.id
        "user:#{current_user.id}"
      else
        request.remote_ip
      end
    end
  end
end
