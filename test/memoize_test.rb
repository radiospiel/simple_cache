require_relative 'test_helper'

class SimpleCache::MemoizeTest < Test::Unit::TestCase
  class X
    attr :cache_key
    
    def initialize(value)
      @value = value
    end

    def cache_key
      @value[0,2]
    end
    
    def do_something
      @value.length
    end
    
    simply_cached :do_something
  end

  def setup
    SimpleCache.url = "#{File.dirname(__FILE__)}/memoize_test"
  end

  def test_simply_cached
    foo = X.new "11"
    assert_equal("11", foo.cache_key)
    assert_equal(2, foo.do_something)
    assert_equal(2, foo.do_something)

    # The following constructs an object with the same cache_key. If the
    # do_something method is properly cached, it must return the identical
    # value; if it was not cached then do_something would return a different
    # value (i.e. 4)
    bar = X.new "1111"
    assert_equal("11", bar.cache_key)
    assert_equal(2, bar.do_something)
    assert_equal(2, bar.do_something)

    # The following constructs an object with a different cache_key. 
    # The do_something method must return a different value.
    baz = X.new "222"
    assert_equal("22", baz.cache_key)
    assert_equal(3, baz.do_something)
    assert_equal(3, baz.do_something)
  end
end
