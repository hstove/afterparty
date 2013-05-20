require 'logger'
require 'afterparty/queue_helpers'
require 'yaml'
Dir[File.expand_path('../afterparty/*', __FILE__)].each { |f| require f }


module Afterparty
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
    # @@redis.smembers "afterparty_queues"
  end

  # return timestamp of :execute_at or current time
  def self.queue_time job
    time = job_valid?(job) ? job.execute_at : DateTime.now
  end

  # returns true if job has an :execute_at value
  def self.job_valid? job
    job.respond_to?(:execute_at) && !job.execute_at.nil?
  end
  
  def self.load(raw)
    begin
      # postgres converts it to utf-8
      # raw.encode!("ascii")
      begin
        # job = Marshal.load(raw)
        # job = Marshal.load(job) if String === job
        return YAML.load(raw)
      rescue ArgumentError => e
        # lots of yaml load errors are because something that hasn't been
        # required. recursively require on these errors
        # Invoke the autoloader and try again if object's class is undefined
        if e.message =~ /undefined class\/module (.*)$/
          # puts "autoloading #{$1}"
          $1.constantize rescue return nil
        end
        return load(raw)
      end
    rescue Exception => e
      puts e
      puts "Exception while unmarshaling a job:"
      puts e.message
      puts e.backtrace
      return nil
    end
  end

end