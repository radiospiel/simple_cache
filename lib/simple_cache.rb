require "uri"

module SimpleCache
end

require_relative "simple_cache/marshal"
require_relative "simple_cache/sqlite_store"

module SimpleCache
  def self.new(url)
    uri = URI.parse(url)
    
    cache = case uri.scheme
    when "redis"        then 
      require_relative "simple_cache/redis_store"
      SimpleCache::RedisStore.new(url)
    when nil, "sqlite"  then 
      SimpleCache::SqliteStore.new(uri.path)
    else                raise uri.scheme.inspect
    end
    
    cache.extend SimpleCache
  end

  singleton_class.class_eval do
    attr :url, true

    def store
      Thread.current["simple_cache_store"] ||= new(url)
    end
  end

  singleton_class.class_eval do
    extend Forwardable
    delegate [:fetch, :store, :cached, :clear] => :store
  end
  
  def cached(key, ttl = nil, &block)
    fetch(key) do
      store(key, yield, ttl)
    end
  end
end
