$:.push File.expand_path('../lib', __FILE__)

require 'service_object/version'

Gem::Specification.new do |s|
  s.name        = 'service_object'
  s.version     = ServiceObject::VERSION
  s.authors     = ['Yukio Mizuta']
  s.email       = ['untidyhair@gmail.com']
  s.homepage    = ''
  s.summary     = 'Small but powerful service objects/service layers library for Rails application.'
  s.description = 'Not only does it let you code complicated business logic easier, but it also helps you keep controllers well-readable and models loose-coupled to each other.'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rails', '>= 4.0.0'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'appraisal'
end
