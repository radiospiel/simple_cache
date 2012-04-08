require_relative 'test_helper'

class SimpleCacheTest < Test::Unit::TestCase
  def test_simple_cache
    SimpleCache.url = "simple_cache_gem"
    SimpleCache.cache_store.clear
    
    assert_equal(nil, SimpleCache.fetch("bar"))

    assert_equal("foo", SimpleCache.store("bar", "foo"))
    assert_equal("foo", SimpleCache.fetch("bar"))
    
    done = 0
    assert_equal "baz", SimpleCache.cached("key") { done += 1; "baz" }
    assert_equal 1, done
    assert_equal "baz", SimpleCache.cached("key") { done += 1; "baz" }
    assert_equal 1, done

    assert_equal(nil, SimpleCache.store("bar", nil))
    assert_equal(nil, SimpleCache.fetch("bar"))
  end
end
