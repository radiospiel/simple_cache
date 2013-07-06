class SimpleCache::NullStore
  def clear
  end
  
  def fetch(key, &block)
    yield self, key if block_given?
  end

  def store(key, value, max_age = nil)
    value
  end
end
