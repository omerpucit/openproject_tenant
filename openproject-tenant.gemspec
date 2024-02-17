$:.push File.expand_path("../lib", __FILE__)
$:.push File.expand_path("../../lib", __dir__)


# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "openproject-tenant"
  s.version = '0.1'
  s.authors     = "OpenProject GmbH"
  s.email       = "info@openproject.org"
  s.homepage    = "https://community.openproject.org/projects/tenant"  # TODO check this URL
  s.summary     = 'OpenProject Tenant'
  s.description = "This is for creating a new tenant"
  s.license     = "MIT" # e.g. "MIT" or "GPLv3"

  s.files = Dir["{app,config,db,lib}/**/*"] + %w(CHANGELOG.md README.md)
  s.require_paths = ["lib"]
  s.add_dependency "rails", '~> 7.0'
end
