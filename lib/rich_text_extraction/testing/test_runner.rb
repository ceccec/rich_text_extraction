# frozen_string_literal: true

module RichTextExtraction
  module Testing
    class TestRunner
      def initialize
        @registry = RichTextExtraction::Registry
        @results = { passed: 0, failed: 0, total: 0, details: {} }
      end

      def run_all_tests
        run_extractor_tests
        run_validator_tests
        run_helper_tests
        run_service_tests
        run_job_tests
        run_controller_tests
        
        @results
      end

      def run_extractor_tests
        @registry.extractors.each do |extractor_name|
          begin
            extractor_class = @registry.get_extractor(extractor_name)
            if extractor_class
              extractor = extractor_class.new
              result = extractor.extract('test content')
              record_test_result(extractor_name, 'extractor', true, result)
            else
              record_test_result(extractor_name, 'extractor', false, 'Class not found')
            end
          rescue => e
            record_test_result(extractor_name, 'extractor', false, e.message)
          end
        end
      end

      def run_validator_tests
        @registry.validators.each do |validator_name|
          begin
            validator_class = @registry.get_validator(validator_name)
            if validator_class
              validator = validator_class.new
              result = validator.respond_to?(:valid?) ? validator.valid?('test') : true
              record_test_result(validator_name, 'validator', true, result)
            else
              record_test_result(validator_name, 'validator', false, 'Class not found')
            end
          rescue => e
            record_test_result(validator_name, 'validator', false, e.message)
          end
        end
      end

      def run_helper_tests
        @registry.helpers.each do |helper_name|
          begin
            helper_class = @registry.get_helper(helper_name)
            if helper_class
              helper = helper_class.new
              result = helper.respond_to?(:extract_links) ? helper.extract_links('test') : true
              record_test_result(helper_name, 'helper', true, result)
            else
              record_test_result(helper_name, 'helper', false, 'Class not found')
            end
          rescue => e
            record_test_result(helper_name, 'helper', false, e.message)
          end
        end
      end

      def run_service_tests
        @registry.services.each do |service_name|
          begin
            service_class = @registry.get_service(service_name)
            if service_class
              service = service_class.new
              result = service.respond_to?(:process) ? service.process('test') : true
              record_test_result(service_name, 'service', true, result)
            else
              record_test_result(service_name, 'service', false, 'Class not found')
            end
          rescue => e
            record_test_result(service_name, 'service', false, e.message)
          end
        end
      end

      def run_job_tests
        @registry.jobs.each do |job_name|
          begin
            job_class = @registry.get_job(job_name)
            if job_class
              record_test_result(job_name, 'job', true, 'Job class found')
            else
              record_test_result(job_name, 'job', false, 'Class not found')
            end
          rescue => e
            record_test_result(job_name, 'job', false, e.message)
          end
        end
      end

      def run_controller_tests
        @registry.controllers.each do |controller_name|
          begin
            controller_class = @registry.get_controller(controller_name)
            if controller_class
              record_test_result(controller_name, 'controller', true, 'Controller class found')
            else
              record_test_result(controller_name, 'controller', false, 'Class not found')
            end
          rescue => e
            record_test_result(controller_name, 'controller', false, e.message)
          end
        end
      end

      private

      def record_test_result(component_name, type, passed, result)
        @results[:total] += 1
        if passed
          @results[:passed] += 1
        else
          @results[:failed] += 1
        end
        
        @results[:details][component_name] = {
          type: type,
          passed: passed,
          result: result,
          timestamp: Time.current
        }
      end
    end
  end
end 