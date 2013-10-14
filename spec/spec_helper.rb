# encoding: utf-8

require 'rubygems'
require 'spork'

Spork.prefork do
  if ENV['COVERAGE']
    require 'simplecov'
    SimpleCov.start do
      add_filter 'spec'
    end
  end

  require 'rspec'
  require 'webmock/rspec'

  WebMock.disable_net_connect!

  require 'roxml'
  require 'nokogiri'
  require 'logger'
  require 'active_model'
  require 'oauth'
end

Spork.each_run do
  require 'quickeebooks'
  Dir[ File.expand_path('../support/{.,**}/*.rb', __FILE__) ].each { |fn| require fn }
end
