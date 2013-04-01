# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  if File.readlines("simple_cache_rs.gemspec").grep(/version/).first =~ /(\d+\.\d+\.\d+)/
    version = $1
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "micro_sql #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


# Add "rake release and rake install"
Bundler::GemHelper.install_tasks
