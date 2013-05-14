require 'logger'
require 'afterparty/queue_helpers'
require 'afterparty/redis_queue'
require 'redis'
Dir[File.expand_path('../afterparty/*', __FILE__)].each { |f| require f }


module Afterparty
  @@redis = Redis.new

  def self.redis
    @@redis
  end
  def self.redis=(redis)
    @@redis = redis
  end
end