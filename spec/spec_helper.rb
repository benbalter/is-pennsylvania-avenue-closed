require "bundler/setup"

ENV['RACK_ENV'] = 'test'
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'rack/test'
require 'webmock/rspec'
require_relative "../lib/server"

WebMock.disable_net_connect!
