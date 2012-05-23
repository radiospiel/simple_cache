require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'ruby-debug'
require 'simplecov'
require 'timecop'
require 'test/unit'
SimpleCov.start do
  add_filter "test/*.rb"
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'simple_cache'

module SimpleCache::TestCase
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
end
