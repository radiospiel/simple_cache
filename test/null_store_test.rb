require_relative 'test_helper'

class SimpleCache::NullStoreTest < Test::Unit::TestCase
  include SimpleCache::TestCase

  URL = "null:"
  
  def simple_cache
    @simple_cache ||= SimpleCache.new(URL).tap(&:clear)
  end
  
  def teardown
    @simple_cache.clear if @simple_cache
  end
end
