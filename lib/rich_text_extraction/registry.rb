# frozen_string_literal: true

module RichTextExtraction
  # RegistryComponent represents a single component in the registry
  # Compatible with OpenGraph and ActiveRecord-style features without database
  class RegistryComponent
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :name, :type, :class_name, :description, :metadata, :active, :created_at, :updated_at, :parent, :children

    validates :name, presence: true
    validates :type, presence: true, inclusion: { in: %w[extractor validator helper service job controller], message: 'must be one of: extractor, validator, helper, service, job, controller' }
    validates :class_name, presence: true

    # Class methods
    def self.types
      %w[extractor validator helper service job controller]
    end

    def self.create!(attributes)
      component = new(attributes)
      component.save!
      component
    end

    def initialize(attributes = {})
      @name = attributes[:name]
      @type = attributes[:type]
      @class_name = attributes[:class_name]
      @description = attributes[:description]
      @metadata = attributes[:metadata] || {}
      @active = attributes[:active] != false
      @created_at = attributes[:created_at] || Time.current
      @updated_at = attributes[:updated_at] || Time.current
      @parent = attributes[:parent]
      @children = attributes[:children] || []
    end

    # OpenGraph compatibility
    def as_opengraph
      {
        "og:title" => name,
        "og:type" => type,
        "og:description" => description,
        "og:updated_time" => updated_at&.iso8601,
        "og:created_time" => created_at&.iso8601
      }.merge(
        (metadata || {}).transform_keys { |k| "og:#{k}" }
      )
    end

    # ActiveRecord-style associations (in-memory)
    def add_child(child)
      @children << child
      child.parent = self
    end

    def remove_child(child)
      @children.delete(child)
      child.parent = nil
    end

    def has_children?
      @children.any?
    end

    def root?
      parent.nil?
    end

    def leaf?
      @children.empty?
    end

    # ActiveRecord-style scopes
    def self.active
      all.select(&:active?)
    end

    def self.inactive
      all.reject(&:active?)
    end

    def self.by_type(type)
      all.select { |c| c.type == type }
    end

    def self.find_by_name(name)
      all.find { |c| c.name == name }
    end

    def self.find_by_type(type)
      all.select { |c| c.type == type }
    end

    # ActiveRecord-style validations
    def self.validates_presence_of(*attrs)
      attrs.each do |attr|
        validates attr, presence: true
      end
    end

    def self.validates_uniqueness_of(attr, options = {})
      scope = options[:scope]
      validates attr, uniqueness: { scope: scope }
    end

    # ActiveRecord-style methods with mathematical error handling
    def save!
      set_defaults
      raise ActiveModel::ValidationError, self unless valid?
      update_timestamps
      Registry.instance.with_error_handling do
        Registry.instance.register_component(self)
      end
      notify_registry
      self
    end

    def save
      save!
      true
    rescue ActiveModel::ValidationError
      false
    end

    def update!(attributes)
      attributes.each { |key, value| send("#{key}=", value) }
      @updated_at = Time.current
      # Use mathematical principle: avoid recursive calls
      Registry.instance.with_error_handling do
        Registry.instance.update_component(self)
      end
      self
    end

    def update(attributes)
      update!(attributes)
      true
    rescue ActiveModel::ValidationError
      false
    end

    def destroy!
      Registry.instance.with_error_handling do
        Registry.instance.unregister_component(self)
      end
    end

    def destroy
      destroy!
      true
    rescue StandardError
      false
    end

    def persisted?
      Registry.instance.component_exists?(name, type)
    end

    def new_record?
      !persisted?
    end

    def active?
      @active
    end

    def inactive?
      !@active
    end

    def activate!
      @active = true
      Registry.instance.with_error_handling do
        Registry.instance.update_component(self)
      end
    end

    def deactivate!
      @active = false
      Registry.instance.with_error_handling do
        Registry.instance.update_component(self)
      end
    end

    # Helper method to get class constant
    def class_constant
      class_name.constantize
    rescue NameError
      nil
    end

    # ActiveRecord-style attributes
    def attributes
      {
        name: @name,
        type: @type,
        class_name: @class_name,
        description: @description,
        metadata: @metadata,
        active: @active,
        created_at: @created_at,
        updated_at: @updated_at,
        parent: @parent,
        children: @children
      }
    end

    def attributes=(new_attributes)
      new_attributes.each { |key, value| send("#{key}=", value) }
    end

    # ActiveRecord-style callbacks implementation
    private

    def set_defaults
      @active = true if @active.nil?
      @metadata ||= {}
      @children ||= []
    end

    def update_timestamps
      @updated_at = Time.current
    end

    def notify_registry
      # Hook for registry notifications
    end

    def self.all
      Registry.instance.components
    end
  end

  # Registry manages all components using ActiveRecord principles with mathematical error handling
  class Registry
    include Singleton
    include ActiveModel::Model

    attr_accessor :components

    # Mathematical constants for error handling and caching
    MATHEMATICAL_RATIO = 1.618033988749895
    MAX_RETRY_ATTEMPTS = 3
    CACHE_TTL = 300 # 5 minutes

    def initialize
      @components = []
      @component_index = {}
      @cache = {}
      @cache_timestamps = {}
      @operation_count = 0
      @error_count = 0
      load_default_components
    end

    # Intelligent caching with mathematical principles
    def cache_get(key)
      return nil unless @cache.key?(key)
      return nil if cache_expired?(key)
      @cache[key]
    end

    def cache_set(key, value, ttl = CACHE_TTL)
      @cache[key] = value
      @cache_timestamps[key] = Time.current + ttl
    end

    def cache_expired?(key)
      return true unless @cache_timestamps.key?(key)
      Time.current > @cache_timestamps[key]
    end

    def cache_clear
      @cache.clear
      @cache_timestamps.clear
    end

    # Mathematical error handling with exponential backoff
    def with_error_handling(max_attempts = MAX_RETRY_ATTEMPTS)
      attempts = 0
      begin
        attempts += 1
        result = yield
        @operation_count += 1 # Count successful operations
        result
      rescue StandardError => e
        @error_count += 1
        if attempts < max_attempts
          # Exponential backoff using mathematical ratio
          sleep_time = (MATHEMATICAL_RATIO ** attempts) * 0.1
          sleep(sleep_time)
          retry
        else
          # Count the final failed operation
          @operation_count += 1
          log_error(e, attempts)
          raise e
        end
      end
    end

    def log_error(error, attempts)
      Rails.logger.error("Registry error after #{attempts} attempts: #{error.message}") if defined?(Rails) && Rails.logger
    end

    # Performance monitoring
    def operation_ratio
      return 0.0 if @operation_count.zero?
      @error_count.to_f / @operation_count
    end

    def should_use_cache?
      operation_ratio < 0.1 # Use cache if error rate is less than 10%
    end

    # ActiveRecord-style query methods with caching
    def self.all
      instance.components
    end

    def self.find_by_name(name)
      cache_key = "find_by_name:#{name}"
      cached_result = instance.cache_get(cache_key)
      return cached_result if cached_result && instance.should_use_cache?
      
      result = instance.find_component_by_name(name)
      instance.cache_set(cache_key, result) if result
      result
    end

    def self.find_by_type(type)
      cache_key = "find_by_type:#{type}"
      cached_result = instance.cache_get(cache_key)
      return cached_result if cached_result && instance.should_use_cache?
      
      result = instance.find_components_by_type(type)
      instance.cache_set(cache_key, result) if result.any?
      result
    end

    def self.where(conditions = {})
      cache_key = "where:#{conditions.hash}"
      cached_result = instance.cache_get(cache_key)
      return cached_result if cached_result && instance.should_use_cache?
      
      result = instance.find_components(conditions)
      instance.cache_set(cache_key, result) if result.any?
      result
    end

    def self.count
      instance.components.count
    end

    def self.exists?(name, type = nil)
      cache_key = "exists:#{name}:#{type}"
      cached_result = instance.cache_get(cache_key)
      return cached_result if cached_result && instance.should_use_cache?
      
      result = instance.component_exists?(name, type)
      instance.cache_set(cache_key, result)
      result
    end

    # Registration methods with mathematical error handling
    def self.register(attributes)
      instance.with_error_handling do
        component = RegistryComponent.new(attributes)
        component.save!
        component
      end
    end

    def self.register_extractor(name, class_name, description: nil, metadata: {})
      register(
        name: name.to_s,
        type: 'extractor',
        class_name: class_name.to_s,
        description: description,
        metadata: metadata
      )
    end

    def self.register_validator(name, class_name, description: nil, metadata: {})
      register(
        name: name.to_s,
        type: 'validator',
        class_name: class_name.to_s,
        description: description,
        metadata: metadata
      )
    end

    def self.register_helper(name, class_name, description: nil, metadata: {})
      register(
        name: name.to_s,
        type: 'helper',
        class_name: class_name.to_s,
        description: description,
        metadata: metadata
      )
    end

    def self.register_service(name, class_name, description: nil, metadata: {})
      register(
        name: name.to_s,
        type: 'service',
        class_name: class_name.to_s,
        description: description,
        metadata: metadata
      )
    end

    def self.register_job(name, class_name, description: nil, metadata: {})
      register(
        name: name.to_s,
        type: 'job',
        class_name: class_name.to_s,
        description: description,
        metadata: metadata
      )
    end

    def self.register_controller(name, class_name, description: nil, metadata: {})
      register(
        name: name.to_s,
        type: 'controller',
        class_name: class_name.to_s,
        description: description,
        metadata: metadata
      )
    end

    # Retrieval methods with caching
    def self.get_extractor(name)
      component = find_by_name(name)
      component&.class_constant if component&.type == 'extractor'
    end

    def self.get_validator(name)
      component = find_by_name(name)
      component&.class_constant if component&.type == 'validator'
    end

    def self.get_helper(name)
      component = find_by_name(name)
      component&.class_constant if component&.type == 'helper'
    end

    def self.get_service(name)
      component = find_by_name(name)
      component&.class_constant if component&.type == 'service'
    end

    def self.get_job(name)
      component = find_by_name(name)
      component&.class_constant if component&.type == 'job'
    end

    def self.get_controller(name)
      component = find_by_name(name)
      component&.class_constant if component&.type == 'controller'
    end

    # Collection methods with caching
    def self.extractors
      cache_key = "extractors"
      cached_result = instance.cache_get(cache_key)
      return cached_result if cached_result && instance.should_use_cache?
      
      result = where(type: 'extractor').map { |c| [c.name, c.class_constant] }.to_h
      instance.cache_set(cache_key, result) if result.any?
      result
    end

    def self.validators
      cache_key = "validators"
      cached_result = instance.cache_get(cache_key)
      return cached_result if cached_result && instance.should_use_cache?
      
      result = where(type: 'validator').map { |c| [c.name, c.class_constant] }.to_h
      instance.cache_set(cache_key, result) if result.any?
      result
    end

    def self.helpers
      cache_key = "helpers"
      cached_result = instance.cache_get(cache_key)
      return cached_result if cached_result && instance.should_use_cache?
      
      result = where(type: 'helper').map { |c| [c.name, c.class_constant] }.to_h
      instance.cache_set(cache_key, result) if result.any?
      result
    end

    def self.services
      cache_key = "services"
      cached_result = instance.cache_get(cache_key)
      return cached_result if cached_result && instance.should_use_cache?
      
      result = where(type: 'service').map { |c| [c.name, c.class_constant] }.to_h
      instance.cache_set(cache_key, result) if result.any?
      result
    end

    def self.jobs
      cache_key = "jobs"
      cached_result = instance.cache_get(cache_key)
      return cached_result if cached_result && instance.should_use_cache?
      
      result = where(type: 'job').map { |c| [c.name, c.class_constant] }.to_h
      instance.cache_set(cache_key, result) if result.any?
      result
    end

    def self.controllers
      cache_key = "controllers"
      cached_result = instance.cache_get(cache_key)
      return cached_result if cached_result && instance.should_use_cache?
      
      result = where(type: 'controller').map { |c| [c.name, c.class_constant] }.to_h
      instance.cache_set(cache_key, result) if result.any?
      result
    end

    def self.total_components
      count
    end

    # Instance methods for internal use with mathematical error handling
    def register_component(component)
      existing = find_component(component.name, component.type)
      if existing
        # Update existing component without recursive calls
        update_component_internal(component)
      else
        @components << component
        @component_index["#{component.type}:#{component.name}"] = component
      end
      cache_clear # Clear cache when registry changes
      component
    end

    def update_component(component)
      update_component_internal(component)
      cache_clear # Clear cache when registry changes
      component
    end

    def update_component_internal(component)
      existing = find_component(component.name, component.type)
      if existing
        # Update attributes without calling save!
        component.attributes.each do |key, value|
          next if key == :created_at # Preserve original creation time
          existing.send("#{key}=", value)
        end
        existing.instance_variable_set(:@updated_at, Time.current)
      end
    end

    def unregister_component(component)
      @components.delete(component)
      @component_index.delete("#{component.type}:#{component.name}")
      cache_clear # Clear cache when registry changes
    end

    def find_component(name, type = nil)
      if type
        @component_index["#{type}:#{name}"]
      else
        @components.find { |c| c.name == name }
      end
    end

    def find_component_by_name(name)
      find_component(name)
    end

    def find_components_by_type(type)
      @components.select { |c| c.type == type }
    end

    def find_components(conditions = {})
      components = @components.dup

      components.select! { |c| c.type == conditions[:type] } if conditions[:type]
      components.select! { |c| c.active == conditions[:active] } if conditions.key?(:active)
      components.select! { |c| c.name.include?(conditions[:name]) } if conditions[:name]

      components
    end

    def component_exists?(name, type = nil)
      if type
        @component_index.key?("#{type}:#{name}")
      else
        @components.any? { |c| c.name == name }
      end
    end

    # Performance monitoring methods
    def performance_stats
      {
        total_operations: @operation_count,
        total_errors: @error_count,
        error_ratio: operation_ratio,
        cache_size: @cache.size,
        component_count: @components.size
      }
    end

    def reset_stats
      @operation_count = 0
      @error_count = 0
    end

    private

    def load_default_components
      # This will be called after all files are loaded
      # Default components will be registered in the main gem file
    end
  end
end 