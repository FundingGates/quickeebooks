$:.unshift File.expand_path("../lib", __FILE__)
require "quickeebooks/version"

Gem::Specification.new do |gem|
  gem.name     = "quickeebooks"
  gem.version  = Quickeebooks::VERSION

  gem.author   = "Cody Caughlan"
  gem.email    = "toolbag@gmail.com"
  gem.homepage = "http://github.com/ruckus/quickeebooks"
  gem.summary  = "REST API to Quickbooks Online/Windows via Intuit Data Services"

  gem.description = gem.summary

  gem.files = Dir["**/*"]

  gem.add_dependency 'roxml', '~> 3.3'
  gem.add_dependency 'oauth', '~> 0.4'
  gem.add_dependency 'nokogiri', '~> 1.5'
  gem.add_dependency 'activemodel', '~> 3.2'
  gem.add_dependency 'uuidtools', '~> 2.1'
  gem.add_dependency 'json', '~> 1.7'

  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'simplecov', '~> 0.7'
  gem.add_development_dependency 'rspec',  '~> 2.11'
  gem.add_development_dependency 'webmock', '~> 1.14'
end
