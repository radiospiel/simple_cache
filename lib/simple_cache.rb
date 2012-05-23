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
    
    cache.extend SimpleCache::Interface
  end

  singleton_class.class_eval do
    attr :url, true

    def url
      @url || raise(ArgumentError, "Missing 'SimpleCache.url' setting.")
    end

    def cache_store
      Thread.current["simple_cache_store"] ||= new(url)
    end

    extend Forwardable
    delegate [:fetch, :store, :clear, :cached] => :cache_store
  end

  module Interface
    def cached(key, ttl = nil, &block)
      fetch(key) do
        value = yield
        store(key, value, ttl) unless ttl == 0 || ttl == false
        value
      end
    end
  end
end
