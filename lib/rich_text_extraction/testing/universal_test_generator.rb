# frozen_string_literal: true

module RichTextExtraction
  module Testing
    # UniversalTestGenerator generates test cases for all interfaces dynamically.
    class UniversalTestGenerator
      # Generate console test cases.
      def self.generate_console_tests
        generate_interface_tests(:console)
      end

      # Generate web test cases.
      def self.generate_web_tests
        generate_interface_tests(:web)
      end

      # Generate JavaScript test cases.
      def self.generate_javascript_tests
        generate_interface_tests(:javascript)
      end

      # Generate integration test cases.
      def self.generate_integration_tests
        generate_interface_tests(:integration)
      end

      # Generate test cases for a specific interface.
      def self.generate_interface_tests(interface)
        test_data.map do |data|
          create_test_case(interface, data)
        end
      end

      # Create a single test case for an interface.
      def self.create_test_case(interface, data)
        {
          name: "#{interface}_#{data[:name]}",
          input: data[:input],
          expected: data[:expected],
          sacred_validation: data[:sacred_validation],
          test_code: generate_test_code(interface, data)
        }
      end

      # Generate test code for a specific interface and data.
      def self.generate_test_code(interface, data)
        case interface
        when :console
          generate_console_test_code(data)
        when :web
          generate_web_test_code(data)
        when :javascript
          generate_javascript_test_code(data)
        when :integration
          generate_integration_test_code(data)
        else
          generate_universal_test_code(data)
        end
      end

      # Generate console-specific test code.
      def self.generate_console_test_code(data)
        "RichTextExtraction::Interfaces::ConsoleInterface.process_text('#{data[:input]}')"
      end

      # Generate web-specific test code.
      def self.generate_web_test_code(data)
        "RichTextExtraction::Universal::InterfaceAdapter.adapt_request(:web, { text: '#{data[:input]}' })"
      end

      # Generate JavaScript-specific test code.
      def self.generate_javascript_test_code(data)
        "RichTextExtraction::Universal::InterfaceAdapter.adapt_request(:javascript, { text: '#{data[:input]}' })"
      end

      # Generate integration-specific test code.
      def self.generate_integration_test_code(data)
        "RichTextExtraction::Testing::UniversalTestRunner.run_single_integration_test(#{data.inspect})"
      end

      # Generate universal test code.
      def self.generate_universal_test_code(data)
        "RichTextExtraction::Universal::InterfaceAdapter.adapt_request(:universal, { text: '#{data[:input]}' })"
      end

      # Universal test data for all interfaces.
      def self.test_data
        [
          {
            name: 'email_extraction',
            input: 'test@example.com',
            expected: { emails: ['test@example.com'] },
            sacred_validation: { golden_ratio: 1.618, vortex_energy: 2.618 }
          },
          {
            name: 'url_extraction',
            input: 'https://example.com',
            expected: { links: ['https://example.com'] },
            sacred_validation: { golden_ratio: 1.618, vortex_energy: 3.141 }
          },
          {
            name: 'comprehensive_extraction',
            input: 'Visit https://example.com and email test@example.com #awesome @user',
            expected: {
              links: ['https://example.com'],
              emails: ['test@example.com'],
              hashtags: ['#awesome'],
              mentions: ['@user']
            },
            sacred_validation: { golden_ratio: 1.618, vortex_energy: 4.669 }
          },
          {
            name: 'phone_extraction',
            input: '+1-555-123-4567',
            expected: { phones: ['+1-555-123-4567'] },
            sacred_validation: { golden_ratio: 1.618, vortex_energy: 2.236 }
          },
          {
            name: 'social_media_extraction',
            input: '@twitter #hashtag https://instagram.com/user',
            expected: {
              mentions: ['@twitter'],
              hashtags: ['#hashtag'],
              links: ['https://instagram.com/user']
            },
            sacred_validation: { golden_ratio: 1.618, vortex_energy: 3.732 }
          }
        ]
      end

      private_class_method :generate_interface_tests, :create_test_case, :generate_test_code,
                           :generate_console_test_code, :generate_web_test_code, :generate_javascript_test_code,
                           :generate_integration_test_code, :generate_universal_test_code, :test_data
    end
  end
end
