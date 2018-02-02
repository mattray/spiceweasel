# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), *%w(lib spiceweasel version))

Gem::Specification.new do |s|
  s.name        = "spiceweasel"
  s.version     = Spiceweasel::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Ray"]
  s.email       = ["matt@chef.io"]
  s.license     = 'Apache-2.0'
  s.homepage    = "https://github.com/mattray/spiceweasel"
  s.summary     = %q{CLI for generating Chef knife commands from a simple JSON or YAML file.}
  s.description = %q{Provides a CLI tool for generating knife commands to build Chef-managed infrastructure from a simple JSON or YAML file.}
  s.required_ruby_version = '>= 1.9'

  s.files         = Dir['LICENSE', 'README.md', 'bin/*', 'lib/**/*']
  s.test_files    = Dir.glob('test/**/*')
  s.executables   = Dir.glob('bin/**/*').map{ |f| File.basename(f) }
  s.require_path  = "lib"

  s.add_dependency('ffi-yajl', '~> 2.3')
  s.add_dependency('mixlib-config', '~> 2.2')
  s.add_dependency('mixlib-cli', '~> 1.7')
  s.add_dependency('mixlib-log', '~> 1.7')
  s.add_dependency('mixlib-shellout', '~> 2.2')
  s.add_dependency('chef', '~> 13.0')
  s.add_dependency('berkshelf', '~> 6.0')
  s.add_development_dependency('rspec', '~> 3')
  s.add_development_dependency('rake', '~> 12')
  s.add_development_dependency('chefstyle', '~> 0.5')
end
