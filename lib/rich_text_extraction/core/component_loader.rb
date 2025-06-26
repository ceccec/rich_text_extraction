# frozen_string_literal: true

module RichTextExtraction
  module Core
    # ComponentLoader follows Rails conventions for loading and registering components
    class ComponentLoader
      include ActiveModel::Model

      attr_accessor :registry

      def initialize(registry = RichTextExtraction::Registry)
        @registry = registry
      end

      # Load all components following Rails autoload conventions
      def load_all!
        load_extractors!
        load_validators!
        load_helpers!
        load_services!
        load_jobs!
        load_controllers!
      end

      # Load extractors
      def load_extractors!
        extractor_configs.each do |config|
          registry.register_extractor(
            config[:name],
            config[:class_name],
            description: config[:description],
            metadata: config[:metadata] || {}
          )
        end
      end

      # Load validators
      def load_validators!
        validator_configs.each do |config|
          registry.register_validator(
            config[:name],
            config[:class_name],
            description: config[:description],
            metadata: config[:metadata] || {}
          )
        end
      end

      # Load helpers
      def load_helpers!
        helper_configs.each do |config|
          registry.register_helper(
            config[:name],
            config[:class_name],
            description: config[:description],
            metadata: config[:metadata] || {}
          )
        end
      end

      # Load services
      def load_services!
        service_configs.each do |config|
          registry.register_service(
            config[:name],
            config[:class_name],
            description: config[:description],
            metadata: config[:metadata] || {}
          )
        end
      end

      # Load jobs
      def load_jobs!
        job_configs.each do |config|
          registry.register_job(
            config[:name],
            config[:class_name],
            description: config[:description],
            metadata: config[:metadata] || {}
          )
        end
      end

      # Load controllers
      def load_controllers!
        controller_configs.each do |config|
          registry.register_controller(
            config[:name],
            config[:class_name],
            description: config[:description],
            metadata: config[:metadata] || {}
          )
        end
      end

      private

      # Configuration methods following Rails convention
      def extractor_configs
        [
          {
            name: 'LinkExtractor',
            class_name: 'RichTextExtraction::Extractors::LinkExtractor',
            description: 'Extracts links from text',
            metadata: { category: 'text_processing', priority: 1 }
          },
          {
            name: 'SocialExtractor',
            class_name: 'RichTextExtraction::Extractors::SocialExtractor',
            description: 'Extracts social media content from text',
            metadata: { category: 'social_media', priority: 1 }
          },
          {
            name: 'IdentifierExtractor',
            class_name: 'RichTextExtraction::Extractors::IdentifierExtractor',
            description: 'Extracts various identifiers from text',
            metadata: { category: 'identifiers', priority: 2 }
          }
        ]
      end

      def validator_configs
        [
          {
            name: 'UrlValidator',
            class_name: 'RichTextExtraction::Validators::UrlValidator',
            description: 'Validates URL format',
            metadata: { category: 'validation', priority: 1 }
          },
          {
            name: 'EmailValidator',
            class_name: 'RichTextExtraction::Validators::EmailValidator',
            description: 'Validates email format',
            metadata: { category: 'validation', priority: 1 }
          },
          {
            name: 'HashtagValidator',
            class_name: 'RichTextExtraction::Validators::HashtagValidator',
            description: 'Validates hashtag format',
            metadata: { category: 'validation', priority: 2 }
          },
          {
            name: 'MentionValidator',
            class_name: 'RichTextExtraction::Validators::MentionValidator',
            description: 'Validates mention format',
            metadata: { category: 'validation', priority: 2 }
          },
          {
            name: 'TwitterHandleValidator',
            class_name: 'RichTextExtraction::Validators::TwitterHandleValidator',
            description: 'Validates Twitter handle format',
            metadata: { category: 'validation', priority: 2 }
          },
          {
            name: 'InstagramHandleValidator',
            class_name: 'RichTextExtraction::Validators::InstagramHandleValidator',
            description: 'Validates Instagram handle format',
            metadata: { category: 'validation', priority: 2 }
          },
          {
            name: 'IpValidator',
            class_name: 'RichTextExtraction::Validators::IpValidator',
            description: 'Validates IP address format',
            metadata: { category: 'validation', priority: 2 }
          },
          {
            name: 'UuidValidator',
            class_name: 'RichTextExtraction::Validators::UuidValidator',
            description: 'Validates UUID format',
            metadata: { category: 'validation', priority: 2 }
          },
          {
            name: 'IsbnValidator',
            class_name: 'RichTextExtraction::Validators::IsbnValidator',
            description: 'Validates ISBN format',
            metadata: { category: 'validation', priority: 2 }
          },
          {
            name: 'IssnValidator',
            class_name: 'RichTextExtraction::Validators::IssnValidator',
            description: 'Validates ISSN format',
            metadata: { category: 'validation', priority: 2 }
          },
          {
            name: 'Ean13Validator',
            class_name: 'RichTextExtraction::Validators::Ean13Validator',
            description: 'Validates EAN-13 format',
            metadata: { category: 'validation', priority: 2 }
          },
          {
            name: 'UpcaValidator',
            class_name: 'RichTextExtraction::Validators::UpcaValidator',
            description: 'Validates UPC-A format',
            metadata: { category: 'validation', priority: 2 }
          },
          {
            name: 'IbanValidator',
            class_name: 'RichTextExtraction::Validators::IbanValidator',
            description: 'Validates IBAN format',
            metadata: { category: 'validation', priority: 2 }
          },
          {
            name: 'VinValidator',
            class_name: 'RichTextExtraction::Validators::VinValidator',
            description: 'Validates VIN format',
            metadata: { category: 'validation', priority: 2 }
          },
          {
            name: 'MacAddressValidator',
            class_name: 'RichTextExtraction::Validators::MacAddressValidator',
            description: 'Validates MAC address format',
            metadata: { category: 'validation', priority: 2 }
          },
          {
            name: 'HexColorValidator',
            class_name: 'RichTextExtraction::Validators::HexColorValidator',
            description: 'Validates hex color format',
            metadata: { category: 'validation', priority: 2 }
          },
          {
            name: 'LuhnValidator',
            class_name: 'RichTextExtraction::Validators::LuhnValidator',
            description: 'Validates Luhn algorithm',
            metadata: { category: 'validation', priority: 2 }
          }
        ]
      end

      def helper_configs
        [
          {
            name: 'HelpersModule',
            class_name: 'RichTextExtraction::Helpers::HelpersModule',
            description: 'Core helpers module for rich text extraction',
            metadata: { category: 'helpers', priority: 1 }
          },
          {
            name: 'InstanceHelpers',
            class_name: 'RichTextExtraction::Helpers::InstanceHelpers',
            description: 'Instance-level helpers',
            metadata: { category: 'helpers', priority: 1 }
          },
          {
            name: 'MarkdownHelpers',
            class_name: 'RichTextExtraction::Helpers::MarkdownHelpers',
            description: 'Markdown processing helpers',
            metadata: { category: 'helpers', priority: 2 }
          },
          {
            name: 'OpenGraphHelpers',
            class_name: 'RichTextExtraction::Helpers::OpenGraphHelpers',
            description: 'OpenGraph processing helpers',
            metadata: { category: 'helpers', priority: 2 }
          },
          {
            name: 'ValidatorHelpers',
            class_name: 'RichTextExtraction::Helpers::ValidatorHelpers',
            description: 'Validation helpers',
            metadata: { category: 'helpers', priority: 2 }
          }
        ]
      end

      def service_configs
        [
          {
            name: 'MarkdownService',
            class_name: 'RichTextExtraction::Services::MarkdownService',
            description: 'Handles markdown rendering',
            metadata: { category: 'services', priority: 1 }
          },
          {
            name: 'OpenGraphService',
            class_name: 'RichTextExtraction::Services::OpenGraphService',
            description: 'Handles OpenGraph data extraction',
            metadata: { category: 'services', priority: 1 }
          }
        ]
      end

      def job_configs
        [
          {
            name: 'ActionTextJob',
            class_name: 'RichTextExtraction::Jobs::ActionTextJob',
            description: 'Processes ActionText content',
            metadata: { category: 'jobs', priority: 1 }
          },
          {
            name: 'BackgroundExtractionJob',
            class_name: 'RichTextExtraction::Jobs::BackgroundExtractionJob',
            description: 'Background job for extraction',
            metadata: { category: 'jobs', priority: 1 }
          }
        ]
      end

      def controller_configs
        [
          {
            name: 'UniversalExtractionController',
            class_name: 'RichTextExtraction::Api::UniversalExtractionController',
            description: 'Universal extraction API controller',
            metadata: { category: 'controllers', priority: 1 }
          }
        ]
      end
    end
  end
end 