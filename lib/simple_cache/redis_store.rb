require "redis"

class SimpleCache::RedisStore
  Marshal = ::SimpleCache::Marshal
  
  def initialize(url)
    @redis = Redis.connect(:url => url)
  end
  
  def clear
    @redis.flushdb
  end
  
  def fetch(key, &block)
    if value = @redis.get(Marshal.uid(key))
      Marshal.unmarshal(value)
    elsif block_given?
      yield self, key
    end
  end

  def store(key, value, max_age = nil)
    cache_id = Marshal.uid(key)
    if value
      @redis.set cache_id, Marshal.marshal(value)
      @redis.expire cache_id, max_age if max_age
    else
      @redis.del cache_id
    end
    value
  end
end
