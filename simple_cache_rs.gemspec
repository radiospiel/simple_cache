Gem::Specification.new do |gem|
  gem.name     = "simple_cache_rs"
  gem.version  = "0.10.1"

  gem.author   = "radiospiel"
  gem.email    = "eno@radiospiel.org"
  gem.homepage = "http://github.com/radiospiel/simple_cache"
  gem.summary  = "A sensibly fast, yet simplistic sqlite- or redis-based cache."

  gem.description = gem.summary

  gem.files = Dir["**/*"].select { |d| d =~ %r{^(README|bin/|data/|ext/|lib/|spec/|test/)} }
end
