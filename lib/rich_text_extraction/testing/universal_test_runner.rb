# frozen_string_literal: true

module RichTextExtraction
  module Testing
    # UniversalTestRunner runs all universal interface tests and ensures code quality.
    class UniversalTestRunner
      # Run all universal tests and RuboCop auto-fix.
      def self.run_all_universal_tests
        puts '🧪 Running Universal Sacred Geometry Tests 🧪'
        run_rubocop_auto_fix
        results = run_all_interface_tests
        generate_universal_test_report(results)
        results
      end

      # Run RuboCop auto-fix and check.
      def self.run_rubocop_auto_fix
        puts '  - Running RuboCop Auto-Fix'
        begin
          require 'rubocop'
          rubocop_result = system('bundle exec rubocop -A --format simple')
          puts rubocop_result ? '    ✅ RuboCop auto-fix completed successfully' : '    ⚠️  RuboCop auto-fix completed with warnings'
          rubocop_check = system('bundle exec rubocop --format simple')
          puts rubocop_check ? '    ✅ All RuboCop violations resolved' : '    ⚠️  Some RuboCop violations remain (manual review needed)'
        rescue LoadError => e
          puts "    ⚠️  RuboCop not available: #{e.message}"
        rescue StandardError => e
          puts "    ❌ RuboCop error: #{e.message}"
        end
      end

      # Run all interface tests and return results hash.
      def self.run_all_interface_tests
        {
          console: run_interface_tests(:console),
          web: run_interface_tests(:web),
          javascript: run_interface_tests(:javascript),
          integration: run_integration_tests
        }
      end

      # Run tests for a single interface.
      def self.run_interface_tests(interface)
        puts "  - Running #{interface.to_s.capitalize} Tests"
        test_cases = UniversalTestGenerator.send("generate_#{interface}_tests")
        test_cases.map { |test_case| run_single_interface_test(interface, test_case) }
      end

      # Run a single test for a given interface.
      def self.run_single_interface_test(interface, test_case)
        result = RichTextExtraction::Universal::InterfaceAdapter.adapt_request(interface, { text: test_case[:input] })
        data_valid = validate_expected_data(result[:data], test_case[:expected])
        sacred_valid = validate_sacred_geometry(result, test_case[:sacred_validation])
        {
          name: "#{interface}_#{test_case[:name]}",
          status: data_valid && sacred_valid[:overall_valid] ? :passed : :failed,
          result: result,
          sacred_validation: sacred_valid,
          data_validation: data_valid
        }
      rescue StandardError => e
        {
          name: "#{interface}_#{test_case[:name]}",
          status: :failed,
          error: e.message
        }
      end

      # Alias for console-specific test running.
      def self.run_single_console_test(test_case)
        run_single_interface_test(:console, test_case)
      end

      def self.run_single_web_test(test_case)
        run_single_interface_test(:web, test_case)
      end

      def self.run_single_javascript_test(test_case)
        run_single_interface_test(:javascript, test_case)
      end

      # Run integration tests (consistency across all interfaces).
      def self.run_integration_tests
        puts '  - Running Integration Tests'
        test_cases = UniversalTestGenerator.generate_integration_tests
        test_cases.map { |test_case| run_single_integration_test(test_case) }
      end

      # Run a single integration test.
      def self.run_single_integration_test(test_case)
        results = %i[console web javascript].map do |iface|
          [iface, RichTextExtraction::Universal::InterfaceAdapter.adapt_request(iface, { text: test_case[:input] })]
        end.to_h
        data_consistent = results.values.map { |r| r[:data] }.uniq.size == 1
        golden_ratio_consistent = results.values.map { |r| r[:golden_ratio] || r[:goldenRatio] }.uniq.size == 1
        {
          name: "integration_#{test_case[:name]}",
          status: data_consistent && golden_ratio_consistent ? :passed : :failed,
          results: results,
          data_consistent: data_consistent,
          golden_ratio_consistent: golden_ratio_consistent
        }
      rescue StandardError => e
        {
          name: "integration_#{test_case[:name]}",
          status: :failed,
          error: e.message
        }
      end

      # Validate that all expected patterns are found in actual data.
      def self.validate_expected_data(actual_data, expected_data)
        expected_data.all? do |pattern_type, expected_items|
          actual_items = actual_data[pattern_type] || []
          expected_items.all? { |item| actual_items.include?(item) }
        end
      end

      # Validate sacred geometry metrics.
      def self.validate_sacred_geometry(result, expected_validation)
        golden_ratio = result[:golden_ratio] || result[:goldenRatio]
        vortex_energy = result.dig(:vortex_flow, :energy) || result.dig(:vortexFlow, :energy)
        golden_ratio_ok = golden_ratio && (golden_ratio - expected_validation[:golden_ratio]).abs < 0.5
        vortex_energy_ok = vortex_energy && (vortex_energy - expected_validation[:vortex_energy]).abs < 10.0
        {
          golden_ratio_valid: golden_ratio_ok,
          vortex_energy_valid: vortex_energy_ok,
          overall_valid: golden_ratio_ok && vortex_energy_ok
        }
      end

      # Generate a universal test report.
      def self.generate_universal_test_report(results)
        puts "\n📊 Universal Test Report 📊"
        results.each do |interface, interface_results|
          puts "\n#{interface.to_s.upcase} Tests:"
          passed = interface_results.count { |r| r[:status] == :passed }
          failed = interface_results.count { |r| r[:status] == :failed }
          puts "  Passed: #{passed}"
          puts "  Failed: #{failed}"
          puts "  Success Rate: #{(passed.to_f / (passed + failed) * 100).round(1)}%"
          next unless failed.positive?

          puts '  Failed Tests:'
          interface_results.select { |r| r[:status] == :failed }.each do |failed_test|
            puts "    - #{failed_test[:name]}: #{failed_test[:error]}"
          end
        end
        check_universal_consistency(results)
      end

      # Check consistency across all interfaces.
      def self.check_universal_consistency(results)
        puts "\n🔍 Universal Consistency Check 🔍"
        integration_tests = results[:integration]
        return unless integration_tests

        consistent_tests = integration_tests.count { |t| t[:status] == :passed }
        total_tests = integration_tests.length
        puts "  Consistent Tests: #{consistent_tests}/#{total_tests}"
        puts "  Consistency Rate: #{(consistent_tests.to_f / total_tests * 100).round(1)}%"
        if consistent_tests == total_tests
          puts '  ✅ All interfaces are perfectly consistent!'
        else
          puts '  ⚠️  Some interfaces show inconsistencies'
        end
      end

      private_class_method :run_rubocop_auto_fix, :run_all_interface_tests,
                           :run_interface_tests, :run_single_interface_test, :run_integration_tests, :run_single_integration_test,
                           :validate_expected_data, :validate_sacred_geometry, :generate_universal_test_report,
                           :check_universal_consistency
    end
  end
end
