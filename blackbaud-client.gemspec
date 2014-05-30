# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'blackbaud-client/version'

Gem::Specification.new do |gem|
  gem.name          = "blackbaud-client"
  gem.version       = Blackbaud::Client::Version.to_s
  gem.authors       = "Alex Dugger"
  gem.email         = "alexd@haikulearning.com"
  gem.description   = "A client for the Blackbaud API."
  gem.homepage      = "https://github.com/haikulearning/blackbaud-api-client"
  gem.summary       = "A client for the Blackbaud API."
  gem.files         = `git ls-files`.split($/)
  gem.require_path  = 'lib'
  gem.add_runtime_dependency     'ruby-hmac'
  gem.add_runtime_dependency     'rest-client'

end