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
  
  s.add_development_dependency "rspec", ["1.3.0"]
  s.add_development_dependency 'livejournal'
  s.add_development_dependency 'twitter'
  s.add_development_dependency 'koala'
  s.add_development_dependency 'flickraw'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
