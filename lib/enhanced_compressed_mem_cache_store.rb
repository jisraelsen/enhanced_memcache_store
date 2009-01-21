class EnhancedCompressedMemCacheStore < EnhancedMemCacheStore  
  def read(key, options = {})
    if value = super(key, options.merge(:raw => true))
      Marshal.load(ActiveSupport::Gzip.decompress(value))
    end
  end

  def write(key, value, options = {})
    super(key, ActiveSupport::Gzip.compress(Marshal.dump(value)), options.merge(:raw => true))
  end
  
  private
    def write_keys(keys, options = {})
      super(keys, options.merge(:raw => true, :compress => true))
    end
end
