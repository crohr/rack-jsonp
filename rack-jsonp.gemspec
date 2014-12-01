# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name                      = "rack-jsonp"
  s.version                   = "1.3.2"
  s.platform                  = Gem::Platform::RUBY
  s.required_ruby_version     = '>= 1.8'
  s.required_rubygems_version = ">= 1.3"
  s.authors                   = ["Cyril Rohr"]
  s.email                     = ["cyril.rohr@gmail.com"]
  s.homepage                  = "http://github.com/crohr/rack-jsonp"
  s.summary                   = "A Rack middleware for providing JSON-P support."
  s.description               = "A Rack middleware for providing JSON-P support."
  s.date = Time.now.strftime("%Y-%m-%d")

  s.add_dependency('rack')
  s.add_development_dependency('rake', '~> 0.8')
  s.add_development_dependency('rspec', '~> 1.3')

  s.files        = Dir.glob("{lib,spec}/**/*") + %w(Rakefile LICENSE README.rdoc)

  s.test_files = [
    "spec/spec_helper.rb",
    "spec/rack_jsonp_spec.rb"
  ]

  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]

  s.rdoc_options = ["--charset=UTF-8"]
  s.require_path = 'lib'
end
