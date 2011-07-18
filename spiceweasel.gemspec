# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), *%w[lib spiceweasel version])

Gem::Specification.new do |s|
  s.name        = "spiceweasel"
  s.version     = Spiceweasel::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Ray", "Elliot Crosby-McCullough"]
  s.email       = ["matt@opscode.com", "elliot.cm@gmail.com"]
  s.homepage    = "http://github.com/mattray/spiceweasel"
  s.summary     = %q{CLI for generating Chef knife commands from a simple YAML file.}
  s.description = %q{This provides a CLI for generating knife commands to build Chef-managed infrastructure from a simple YAML file.}

  s.rubyforge_project = "spiceweasel"

  s.files         = Dir.glob('{bin,lib}/**/*') + ['README.md']
  s.test_files    = Dir.glob('spec/**/*')
  s.executables   = Dir.glob('bin/**/*').map{ |f| File.basename(f) }
  s.require_path  = "lib"

  s.add_dependency('chef')
  s.add_dependency('json')
  s.add_dependency('mixlib-cli')
  s.add_development_dependency('rspec')
end
