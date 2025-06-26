# frozen_string_literal: true

module RichTextExtraction
  module Testing
    class TestGenerator
      def initialize
        @registry = RichTextExtraction::Registry
      end

      def generate_all_tests
        {
          extractors: generate_extractor_tests,
          validators: generate_validator_tests,
          helpers: generate_helper_tests,
          services: generate_service_tests,
          jobs: generate_job_tests,
          controllers: generate_controller_tests
        }
      end

      def generate_extractor_tests
        tests = {}
        @registry.extractors.each do |extractor_name|
          tests[extractor_name] = {
            name: extractor_name,
            type: 'extractor',
            test_methods: ['extract', 'valid_input', 'invalid_input'],
            sample_data: generate_sample_data(extractor_name)
          }
        end
        tests
      end

      def generate_validator_tests
        tests = {}
        @registry.validators.each do |validator_name|
          tests[validator_name] = {
            name: validator_name,
            type: 'validator',
            test_methods: ['valid?', 'valid_input', 'invalid_input'],
            sample_data: generate_sample_data(validator_name)
          }
        end
        tests
      end

      def generate_helper_tests
        tests = {}
        @registry.helpers.each do |helper_name|
          tests[helper_name] = {
            name: helper_name,
            type: 'helper',
            test_methods: ['extract_links', 'extract_mentions', 'extract_hashtags'],
            sample_data: generate_sample_data(helper_name)
          }
        end
        tests
      end

      def generate_service_tests
        tests = {}
        @registry.services.each do |service_name|
          tests[service_name] = {
            name: service_name,
            type: 'service',
            test_methods: ['process', 'transform', 'analyze'],
            sample_data: generate_sample_data(service_name)
          }
        end
        tests
      end

      def generate_job_tests
        tests = {}
        @registry.jobs.each do |job_name|
          tests[job_name] = {
            name: job_name,
            type: 'job',
            test_methods: ['perform', 'enqueue', 'execute'],
            sample_data: generate_sample_data(job_name)
          }
        end
        tests
      end

      def generate_controller_tests
        tests = {}
        @registry.controllers.each do |controller_name|
          tests[controller_name] = {
            name: controller_name,
            type: 'controller',
            test_methods: ['index', 'show', 'create', 'update', 'destroy'],
            sample_data: generate_sample_data(controller_name)
          }
        end
        tests
      end

      private

      def generate_sample_data(component_name)
        case component_name.downcase
        when /link/
          ['https://example.com', 'http://test.org', 'invalid-url']
        when /social|mention|hashtag/
          ['@user123', '#ruby', '#rails', 'invalid-mention']
        when /validator/
          ['valid_value', 'invalid_value', '']
        when /service/
          ['sample_data', 'test_input', 'processed_output']
        when /job/
          ['job_data', 'background_task', 'async_operation']
        when /controller/
          ['request_data', 'response_data', 'api_call']
        else
          ['sample_input', 'test_data', 'default_value']
        end
      end
    end
  end
end 