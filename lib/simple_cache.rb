require "uri"

module SimpleCache
end

require_relative "simple_cache/marshal"
require_relative "simple_cache/sqlite_store"
require_relative "simple_cache/redis_store"

module SimpleCache
  def self.new(url)
    case url 
    when Redis, Redis::Namespace then
      return SimpleCache::RedisStore.new(url)
    end

    uri = URI.parse(url)
    
    cache = case uri.scheme
    when "redis"        then 
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

    def fetch(key, &block)
      key = SimpleCache.cache_key(key)
      cache_store.fetch(key, &block)
    end
    
    def store(key, value)
      key = SimpleCache.cache_key(key)
      cache_store.store key, value
    end
    
    def clear(key)
      key = SimpleCache.cache_key(key)
      cache_store.clear key
    end
    
    def cached(key, ttl = nil, &block)
      key = SimpleCache.cache_key(key)
      cache_store.cached key, ttl, &block
    end
  end

  module Interface
    @@requests = @@misses = 0

    def cached(key, ttl = nil, &block)
      @@requests += 1
      
      fetch(key) do
        @@misses += 1

        value = yield
        store(key, value, ttl) unless ttl == 0 || ttl == false
        value
      end
    end

    def self.stats
      return {} if @@requests == 0
      
      {
        :hits => @@requests - @@misses,
        :misses => @@misses
      }
    end
  end

  def self.cache_key(obj)
    return SimpleCache::Marshal.md5(obj.cache_key) if obj.respond_to?(:cache_key)

    case obj
    when String
      SimpleCache::Marshal.md5 obj
    when Hash
      parts = []
      obj.each { |k,v| parts << cache_key(k) << cache_key(v) }
      SimpleCache::Marshal.md5 parts.join("/")
    when Array
      parts = obj.map { |part| cache_key(part) }
      SimpleCache::Marshal.md5 parts.join(":")
    else
      SimpleCache::Marshal.md5 self.inspect
    end
  end
  
  # The SimplyCached module contains a method to easily implement
  # memoized-like caching on top of SimpleCache
  module SimplyCached
    def simply_cached(method, options = {})
      ttl = options[:ttl]

      uncached_method = "#{method}__uncached".to_sym

      alias_method uncached_method, method

      define_method(method) do |*args|
        cache_key = args.empty? ? self : [ self ] + args
        current_ttl = if ttl.respond_to?(:call)
          ttl.send(:call, *args)
        else
          ttl
        end

        SimpleCache.cached(cache_key, current_ttl) do
          self.send uncached_method, *args
        end 
      end
    end
  end
end

class Module
  include SimpleCache::SimplyCached
end

at_exit do
  stats = SimpleCache::Interface.stats
  next if stats.empty?
  
  STDERR.puts "SimpleCache stats: #{stats[:hits]} hits, #{stats[:misses]} misses"
end
