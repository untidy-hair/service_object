$:.push File.expand_path('../lib', __FILE__)

require 'service_object/version'

Gem::Specification.new do |s|
  s.name        = 'service_object'
  s.version     = ServiceObject::VERSION
  s.authors     = ['Yukio Mizuta']
  s.email       = ['untidyhair@gmail.com']
  s.homepage    = 'http://y-mzt.info'
  s.summary     = 'ServiceObject which interacts with model domain logic and controllers.'
  s.description = 'ServiceObject which interacts with model domain logic and controllers.'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rails', '>= 3.2.0'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'rspec'
end
