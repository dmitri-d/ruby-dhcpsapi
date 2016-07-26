$:.push File.expand_path("../lib", __FILE__)

require "dhcpsapi/version"

Gem::Specification.new do |gem|
  gem.authors               = ["Dmitri Dolguikh"]
  gem.email                 = 'dmitri@appliedlogic.ca'
  gem.description           = 'Ruby wrappers for MS DHCP api'
  gem.summary               = 'Ruby wrappers for MS DHCP api'
  gem.homepage              = "https://github.com/witlessbird/ruby-dhcpsapi"
  gem.license               = "Apache License, v2.0"

  gem.files                 = %w(LICENSE.txt README.md Rakefile) + Dir["lib/**/*"]
  gem.name                  = "dhcpsapi"
  gem.require_path          = "lib"
  gem.version               = DhcpsApi::VERSION

  gem.add_dependency 'ffi'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'yard'
end
