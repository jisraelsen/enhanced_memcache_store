class EnhancedMemCacheStore < ActiveSupport::Cache::MemCacheStore
  module Common
    KEY = 'enhanced_memcached_keys'
  end
  
  def write(key, value, options = nil)
    if written = super
      add_key(key) unless options && options[:expires_in]
    end
    
    written
  end
  
  def delete(key, options = nil)
    if deleted = super
      remove_key(key)
    end
    
    deleted
  end
  
  def delete_matched(matcher, options = nil)
    deleted_keys = keys.select { |key| key =~ matcher && delete(key, options) }

    remove_keys(deleted_keys) unless deleted_keys.empty?
    
    !deleted_keys.empty?
  end
  
  def keys
    (cached_keys = read(Common::KEY)) ? YAML.load(cached_keys).to_a : []
  end
  
  private
    def add_key(key)
      add_keys([key]) unless keys.include?(key)
    end
    
    def remove_key(key)
      remove_keys([key]) if keys.include?(key)
    end
    
    def add_keys(keys_to_add)
      write_keys(keys+keys_to_add)
    end
    
    def remove_keys(keys_to_remove)
      write_keys(keys-keys_to_remove)
    end
    
    def write_keys(keys, options = nil)
      compress = options.delete(:compress) if options
      value = compress ? ActiveSupport::Gzip.compress(Marshal.dump(keys.to_yaml)) : keys.to_yaml
      response = @data.send(:set, Common::KEY, value, expires_in(options), raw?(options))
      return true if response.nil?
      response == Response::STORED
    rescue MemCache::MemCacheError => e
      logger.error("MemCacheError (#{e}): #{e.message}")
      false
    end
end