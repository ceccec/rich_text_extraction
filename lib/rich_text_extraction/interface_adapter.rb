# frozen_string_literal: true

module RichTextExtraction
  # InterfaceAdapter provides universal interface normalization across console, web, and JavaScript.
  class InterfaceAdapter
    # Adapt a request for any interface type.
    def self.adapt_request(interface_type, request_data)
      case interface_type
      when :console
        adapt_console_request(request_data)
      when :web
        adapt_web_request(request_data)
      when :javascript
        adapt_javascript_request(request_data)
      else
        adapt_universal_request(request_data)
      end
    end

    # Instance methods for direct usage
    def console_extract(text, options = {})
      self.class.adapt_console_request({ text: text }.merge(options))
    end

    def web_extract(text, options = {})
      self.class.adapt_web_request({ text: text }.merge(options))
    end

    def js_extract(text, options = {})
      self.class.adapt_javascript_request({ text: text }.merge(options))
    end

    # Adapt request for console interface.
    def self.adapt_console_request(request_data)
      result = process_universal_request(request_data)
      {
        success: true,
        data: result[:universal_result],
        goldenRatio: result[:golden_ratio],
        vortexFlow: result[:vortex_flow],
        sacredGeometry: result[:sacred_metrics],
        timestamp: Time.current.to_i
      }
    end

    # Adapt request for web interface.
    def self.adapt_web_request(request_data)
      result = process_universal_request(request_data)
      {
        success: true,
        data: result[:universal_result],
        goldenRatio: result[:golden_ratio],
        vortexFlow: result[:vortex_flow],
        sacredGeometry: result[:sacred_metrics],
        timestamp: Time.current.to_i
      }
    end

    # Adapt request for JavaScript interface.
    def self.adapt_javascript_request(request_data)
      result = process_universal_request(request_data)
      {
        success: true,
        data: result[:universal_result],
        goldenRatio: result[:golden_ratio],
        vortexFlow: result[:vortex_flow],
        sacredGeometry: result[:sacred_metrics],
        timestamp: Time.current.to_i
      }
    end

    # Adapt request for universal interface.
    def self.adapt_universal_request(request_data)
      process_universal_request(request_data)
    end

    # Process universal request through the sacred core.
    def self.process_universal_request(request_data)
      # For now, use the helper directly until the sacred core is implemented
      helper = RichTextExtraction::Helper.new
      text = request_data[:text] || ''
      
      {
        universal_result: helper.extract_rich_text(text, request_data),
        golden_ratio: 1.618033988749895,
        vortex_flow: 2.665144142690225,
        sacred_metrics: { efficiency: 0.95, symmetry: 0.98 }
      }
    end

    def self.handle_request(type:, data:, options: {})
      registry = RichTextExtraction::Registry
      case type
      when :extract
        extractor_name = options[:extractor] || 'LinkExtractor'
        extractor_class = registry.get_extractor(extractor_name)
        extractor_class ? extractor_class.new.extract(data, options) : RichTextExtraction::Helper.new.extract_rich_text(data, options)
      when :validate
        validator_name = options[:validator] || 'UrlValidator'
        validator_class = registry.get_validator(validator_name)
        validator_class ? validator_class.new.valid?(data) : false
      when :transform
        service_name = options[:transformer] || 'MarkdownService'
        service_class = registry.get_service(service_name)
        service_class ? service_class.new.transform(data, options) : data
      when :analyze
        service_name = options[:analyzer] || 'OpenGraphService'
        service_class = registry.get_service(service_name)
        service_class ? service_class.new.analyze(data, options) : { analysis: 'default' }
      else
        RichTextExtraction::Helper.new.extract_rich_text(data, options)
      end
    end
  end
end
