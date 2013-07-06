require_relative 'test_helper'

class SimpleCache::MemcachedStoreTest < Test::Unit::TestCase
  include SimpleCache::TestCase

  def simple_cache
    @simple_cache ||= begin
      simple_cache = SimpleCache.new("memcached://localhost:11211/simple_cache_test")
      simple_cache.clear
      simple_cache
    end
  end
  
  def test_expiration
    assert_equal("1", simple_cache.store("forever", "1"))
    assert_equal("2", simple_cache.store("young", "2", 3))

    # Timecop tests don't work here :(
    #
    # Timecop.freeze(Time.now + 10) do
    #   assert_equal("1", simple_cache.fetch("forever"))
    #   assert_equal(nil, simple_cache.fetch("young"))
    # end
  end
  
  def test_array
    ary = %w(foo bar)
    assert_equal(ary, simple_cache.store("ary", ary))
    assert_equal(ary, simple_cache.fetch("ary"))
  end
end
