require_relative 'helper'
require 'timecop'

class TestSimpleCache < Test::Unit::TestCase
  def simple_cache
    @simple_cache ||= SimpleCache.new("simple_cache_test").tap(&:clear)
  end
  
  def teardown
    File.unlink @simple_cache.path if @simple_cache
  end
  
  def test_simple_cache
    assert_equal(nil, simple_cache.get("bar"))

    assert_equal("foo", simple_cache.set("bar", "foo"))
    assert_equal("foo", simple_cache.get("bar"))
    
    done = 0
    assert_equal "baz", simple_cache.cached("key") { done += 1; "baz" }
    assert_equal 1, done
    assert_equal "baz", simple_cache.cached("key") { done += 1; "baz" }
    assert_equal 1, done

    assert_equal(nil, simple_cache.set("bar", nil))
    assert_equal(nil, simple_cache.get("bar"))
  end

  def test_expiration
    assert_equal("1", simple_cache.set("forever", "1"))
    assert_equal("2", simple_cache.set("young", "2", 3))
    Timecop.freeze(Time.now + 10) do
      assert_equal("1", simple_cache.get("forever"))
      assert_equal(nil, simple_cache.get("young"))
    end
  end

  def test_explicit_expiration
    assert_equal("2", simple_cache.set("young", "2"))
    simple_cache.expire("young", 3)

    Timecop.freeze(Time.now + 2) do
      assert_equal("2", simple_cache.get("young"))
    end

    Timecop.freeze(Time.now + 10) do
      assert_equal(nil, simple_cache.get("young"))
    end
  end
end
