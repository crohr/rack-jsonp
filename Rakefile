require "bundler"
Bundler.setup

require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rack-jsonp"
    gem.summary = %Q{A Rack middleware for providing JSON-P support.}
    gem.description = %Q{A Rack middleware for providing JSON-P support.}
    gem.email = "cyril.rohr@gmail.com"
    gem.homepage = "http://github.com/crohr/rack-jsonp"
    gem.authors = ["Cyril Rohr"]
    
    gem.add_dependency('rack')
    gem.add_development_dependency('rake')
    gem.add_development_dependency('jeweler')
    gem.add_development_dependency('rspec', '~> 2.0.0')
    
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:rcov) do |task|
  task.rcov = true
end

task :default => :spec
require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rack-jsonp #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
