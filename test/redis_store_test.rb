require_relative 'test_helper'

class SimpleCache::RedisStoreTest < Test::Unit::TestCase
  include SimpleCache::TestCase

  URL = "redis://localhost/1"
  
  def simple_cache
    @simple_cache ||= SimpleCache.new(URL).tap(&:clear)
  end
  
  def teardown
    @simple_cache.clear if @simple_cache
  end
end
