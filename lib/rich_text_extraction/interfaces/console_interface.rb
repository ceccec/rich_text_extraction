# frozen_string_literal: true

module RichTextExtraction
  module Interfaces
    # ConsoleInterface provides console-based text processing and display.
    class ConsoleInterface
      # Process text through console interface.
      def self.process_text(text)
        result = RichTextExtraction::Universal::InterfaceAdapter.adapt_request(:console, { text: text })
        display_console_result(result)
        result
      end

      # Display console result with sacred geometry metrics.
      def self.display_console_result(result)
        puts '=== Sacred Geometry Extraction Results ==='
        display_input(result[:input])
        display_extracted_data(result[:data])
        display_sacred_geometry_metrics(result)
        display_sacred_geometry_compliance(result)
      end

      # Display input text.
      def self.display_input(input)
        puts "Input: #{input}\n"
      end

      # Display extracted data patterns.
      def self.display_extracted_data(data)
        puts 'Extracted Data:'
        display_patterns(data)
        puts
      end

      # Display individual patterns.
      def self.display_patterns(data)
        pattern_types = %w[links emails phones hashtags mentions]
        pattern_types.each do |type|
          items = data[type.to_sym] || []
          puts "  #{type.capitalize}: #{items.join(', ')}" if items.any?
        end
        puts "  Sacred_patterns: #{data[:sacred_patterns]}" if data[:sacred_patterns]
      end

      # Display sacred geometry metrics.
      def self.display_sacred_geometry_metrics(result)
        puts 'Sacred Geometry Metrics:'
        puts "  Golden Ratio: #{result[:golden_ratio]}"
        puts "  Vortex Energy: #{result[:vortex_flow][:energy]}"
        puts "  Flow Efficiency: #{result[:vortex_flow][:flow_efficiency]}"
        puts "  Sacred Balance: #{result[:vortex_flow][:sacred_balance]}"
        puts
      end

      # Display sacred geometry compliance.
      def self.display_sacred_geometry_compliance(result)
        puts 'Sacred Geometry Compliance:'
        metrics = result[:sacred_geometry]
        puts "  Golden Ratio Compliance: #{metrics[:golden_ratio_compliance]}"
        puts "  Fibonacci Index: #{metrics[:fibonacci_index]}"
        puts "  Vortex Constant Ratio: #{metrics[:vortex_constant_ratio]}"
        puts "  Sacred Balance Score: #{metrics[:sacred_balance_score]}"
        puts
      end

      # Process multiple texts in batch.
      def self.batch_process(texts)
        puts '=== Batch Sacred Geometry Processing ==='
        puts "Processing #{texts.length} texts...\n"
        results = []
        texts.each_with_index do |text, index|
          puts "Processing text #{index + 1}/#{texts.length}..."
          result = process_text(text)
          results << result
        end
        display_batch_summary(results)
        results
      end

      # Display batch processing summary.
      def self.display_batch_summary(results)
        puts "\n=== Batch Processing Summary ==="
        puts "Total processed: #{results.length}"
        display_average_metrics(results)
        display_best_worst_balance(results)
      end

      # Display average metrics across all results.
      def self.display_average_metrics(results)
        avg_golden_ratio = results.map { |r| r[:golden_ratio] }.sum / results.length
        avg_vortex_energy = results.map { |r| r[:vortex_flow][:energy] }.sum / results.length
        avg_balance_score = results.map { |r| r[:sacred_geometry][:sacred_balance_score] }.sum / results.length
        puts "Average Golden Ratio: #{avg_golden_ratio}"
        puts "Average Vortex Energy: #{avg_vortex_energy}"
        puts "Average Sacred Balance Score: #{avg_balance_score}"
      end

      # Display best and worst sacred balance scores.
      def self.display_best_worst_balance(results)
        balance_scores = results.map { |r| r[:sacred_geometry][:sacred_balance_score] }
        best_balance = balance_scores.max
        worst_balance = balance_scores.min
        puts "Best Sacred Balance: #{best_balance}"
        puts "Worst Sacred Balance: #{worst_balance}"
        puts
      end

      private_class_method :display_console_result, :display_input, :display_extracted_data,
                           :display_patterns, :display_sacred_geometry_metrics, :display_sacred_geometry_compliance,
                           :display_batch_summary, :display_average_metrics, :display_best_worst_balance
    end
  end
end
