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

  s.add_dependency('ffi-yajl', '~> 1.1')
  s.add_dependency('mixlib-config', '~> 2.1')
  s.add_dependency('mixlib-cli', '~> 1.5')
  s.add_dependency('mixlib-log', '~> 1.6')
  s.add_dependency('mixlib-shellout', '~> 1.4')
  s.add_dependency('chef', '~> 11.16')
  s.add_dependency('berkshelf', '~> 3.1')
  s.add_development_dependency('rspec', '~> 3')
  s.add_development_dependency('rake', '~> 10.3')
  s.add_development_dependency('rubocop', '~> 0.18.1')
end
