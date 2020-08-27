require "auto_invalid_cache/version"

module AutoInvalidCache
  extend ActiveSupport::Concern

  included do
    extend ClassMethods
    include InstanceMethods
    after_save :delete_caches
    after_destroy :delete_caches
    after_touch :delete_caches
  end

  module InstanceMethods
    def cache(cache_namespace, **options, &block)
      if cache_namespace.is_a?(String) || cache_namespace.is_a?(Symbol)
        cache_key = generate_cache_key(cache_namespace.to_s)
      else
        raise "cache_namespace must be String or Symbol"
      end
      Rails.cache.fetch(cache_key, **options) do
        self.class.auto_invalid_cache_keys_add(cache_key)
        yield block if block_given?
      end
    end

    def delete_caches
      self.class.auto_invalid_cache_keys.each do |ck|
        Rails.cache.delete(ck)
      end
    end

    def generate_cache_key(cache_namespace)
      "#{self.class.name}/#{id}/#{cache_namespace}"
    end
  end

  module ClassMethods
    def self.extended(base)
      base.class_variable_set(:@@auto_invalid_cache_keys, [])
    end

    def auto_invalid_cache_keys
      class_variable_get(:@@auto_invalid_cache_keys).uniq
    end

    def auto_invalid_cache_keys_add(key)
      class_variable_set(:@@auto_invalid_cache_keys, auto_invalid_cache_keys << key)
    end
  end
end
