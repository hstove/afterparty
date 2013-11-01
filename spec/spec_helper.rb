require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter "/spec/"
end

require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'redis'
require 'afterparty' # and any other gems you need
require 'helpers'
require 'genspec'
require 'fileutils'

RSpec.configure do |config|
  # some (optional) config here
  config.include Afterparty::QueueTestHelpers
end

database_yml = File.expand_path("../database.yml", __FILE__)
active_record_config = YAML.load_file(database_yml)
ActiveRecord::Base.configurations = active_record_config
ActiveRecord::Base.establish_connection("sqlite3")

load(File.dirname(__FILE__) + "/schema.rb")

def clean_database!
  ActiveRecord::Base.connection.execute "DELETE FROM afterparty_jobs"
end

clean_database!
