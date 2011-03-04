# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "spiceweasel/version"

Gem::Specification.new do |s|
  s.name        = "spiceweasel"
  s.version     = Spiceweasel::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Ray"]
  s.email       = ["matt@opscode.com"]
  s.homepage    = ""
  s.summary     = %q{CLI for generating Chef knife commands from a simple YAML file.}
  s.description = %q{This provides a CLI for generating knife commands to build Chef-managed infrastructure from a simple YAML file.}

  s.rubyforge_project = "spiceweasel"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
