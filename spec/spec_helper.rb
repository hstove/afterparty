require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'redis'
require 'afterparty' # and any other gems you need
require 'helpers'

RSpec.configure do |config|
  # some (optional) config here
  config.include Afterparty::QueueTestHelpers
end