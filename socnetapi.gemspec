# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "socnetapi/version"

Gem::Specification.new do |s|
  s.name        = "socnetapi"
  s.version     = Socnetapi::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Iurii 'dorialan' Marchenko"]
  s.email       = ["dorialan@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Social networks API combinator}
  s.description = %q{Combines Social networks APIs}

  s.rubyforge_project = "socnetapi"
  
  s.add_development_dependency "rspec", [">= 2.5"]
  s.add_dependency 'livejournal'
  s.add_dependency 'twitter'
  s.add_dependency 'koala'
  s.add_dependency 'flickraw'
  s.add_dependency 'oauth'
  s.add_dependency 'mime-types'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'nokogiri'
end
