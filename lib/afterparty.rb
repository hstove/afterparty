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

  def self.clear namespace=:default
    redis_call namespace, :del
  end

  def self.redis_call namespace, command, *args
    @@redis.send(command, redis_queue_name(namespace), *args)
  end

  def self.redis_queue_name namespace=:default
    "afterparty_#{namespace}_queue"
  end

  def self.queues
    @@redis.smembers "afterparty_queues"
  end

  def self.add_queue name
    @@redis.sadd "afterparty_queues", name
  end

  def self.next_job_id namespace=:default
    @@redis.incr "afterparty_#{namespace.to_s}_job_id"
  end

  def self.load(raw)
    begin
      begin
        job = Marshal.load(raw)
        job = Marshal.load(job) if String === job
        return job
      rescue NameError => e
        # lots of marshal load errors are because something that hasn't been
        # required. recursively require on these errors
        name = e.message.gsub("uninitialized constant ","").downcase
        begin
          require "#{name}"
          return load(raw)
        rescue LoadError
        end
      end
    rescue
      return nil
    end
  end

end