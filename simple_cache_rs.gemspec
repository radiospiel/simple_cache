Gem::Specification.new do |gem|
  gem.name     = "simple_cache_rs"
  gem.version  = "0.10.3"

  gem.author   = "radiospiel"
  gem.email    = "eno@radiospiel.org"
  gem.homepage = "http://github.com/radiospiel/simple_cache"
  gem.summary  = "A sensibly fast, yet simplistic sqlite- or redis-based cache."

  gem.description = gem.summary

  # gem.add_dependency "sqlite3"
  gem.add_dependency "expectation"
  gem.add_dependency "redis"
  gem.add_dependency "redis-namespace"
  
  gem.files = Dir["**/*"].select { |d| d =~ %r{^(README|bin/|data/|ext/|lib/|spec/|test/)} }
end
