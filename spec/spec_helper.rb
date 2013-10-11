# encoding: utf-8

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'spec'
  end
end

require 'rubygems'
require 'rspec'
require 'fakeweb'
require 'quickeebooks'

RSpec.configure do |config|
  config.color_enabled = true
end

Dir[ File.expand_path('../support/{.,**}/*.rb', __FILE__) ].each { |fn| require fn }
