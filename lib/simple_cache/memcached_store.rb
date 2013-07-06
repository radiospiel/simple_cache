class SimpleCache::MemcachedStore
  Marshal = ::SimpleCache::Marshal
  
  def initialize(url)
    require "dalli"

    uri = URI.parse(url)

    @dc = Dalli::Client.new "#{uri.host}:#{uri.port}", 
      :namespace => (uri.path == "/" || uri.path == "" ? "simple_cache" : uri.path), 
      :compress => true,
      :username => uri.user,
      :password => uri.password
  end
  
  def fetch(key, &block)
    value = @dc.get(key)
    return Marshal.unmarshal(value) if value
    return yield(self, key) if block
    nil
  end

  def store(key, value, ttl = nil)
    @dc.set(key, Marshal.marshal(value), ttl)
    value
  end

  def clear
    @dc.flush_all
  end
end
