require_relative 'test_helper'

class SimpleCache::PgStoreTest < Test::Unit::TestCase
  include SimpleCache::TestCase

  def simple_cache
    @simple_cache ||= SimpleCache.new("pg://simple_cache:simple_cache@localhost/simple_cache_test").tap(&:clear)
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
