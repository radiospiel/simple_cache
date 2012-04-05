require_relative 'test_helper'

class TestSimpleCache < Test::Unit::TestCase
  def simple_cache
    @simple_cache ||= SimpleCache.new("simple_cache_test").tap(&:clear)
  end
  
  def teardown
    File.unlink @simple_cache.path if @simple_cache
  end
  
  def test_simple_cache
    assert_equal(nil, simple_cache.fetch("bar"))

    assert_equal("foo", simple_cache.store("bar", "foo"))
    assert_equal("foo", simple_cache.fetch("bar"))
    
    done = 0
    assert_equal "baz", simple_cache.cached("key") { done += 1; "baz" }
    assert_equal 1, done
    assert_equal "baz", simple_cache.cached("key") { done += 1; "baz" }
    assert_equal 1, done

    assert_equal(nil, simple_cache.store("bar", nil))
    assert_equal(nil, simple_cache.fetch("bar"))
  end

  def test_expiration
    assert_equal("1", simple_cache.store("forever", "1"))
    assert_equal("2", simple_cache.store("young", "2", 3))
    Timecop.freeze(Time.now + 10) do
      assert_equal("1", simple_cache.fetch("forever"))
      assert_equal(nil, simple_cache.fetch("young"))
    end
  end
end
