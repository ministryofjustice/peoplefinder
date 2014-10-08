$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "peoplefinder/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "peoplefinder"
  s.version     = Peoplefinder::VERSION
  s.authors     = ["Toby Privett", "David Heath", "Paul Battley", "James Darling"]
  s.email       = ["people-finder@digital.justice.gov.uk"]
  s.homepage    = "http://github.com/ministryofjustice/peoplefinder"
  s.summary     = "Searchable people database for your organisation"
  s.description = "The peoplefinder provides searchable staff profiles for your organisation. Since it's a rails engine, you can re-skin it for your organisation."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENCE.txt", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.1.5"
end
