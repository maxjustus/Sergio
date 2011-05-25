# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sergio/version"

Gem::Specification.new do |s|
  s.name        = "sergio"
  s.version     = Sergio::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Max Justus Spransy"]
  s.email       = ["maxjustus@gmail.com"]
  s.homepage    = "https://github.com/maxjustus/Sergio"
  s.summary     = %q{SAXy xml to hash transformation.}
  s.description = %q{
      Sergio provides a declarative syntax for parsing unruly xml into nice pretty hashes.
    }

  s.rubyforge_project = "sergio"

  s.add_dependency 'nokogiri'
  s.add_development_dependency 'rspec', '~> 2.5.0'
  s.add_development_dependency 'rake'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
