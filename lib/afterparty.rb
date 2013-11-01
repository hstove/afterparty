require 'logger'
require 'afterparty/queue_helpers'
require 'yaml'
Dir[File.expand_path('../afterparty/*', __FILE__)].each { |f| require f }


module Afterparty

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
      begin
        return YAML.load(raw)
      rescue ArgumentError => e
        # lots of yaml load errors are because something that hasn't been
        # required. recursively require on these errors
        # Invoke the autoloader and try again if object's class is undefined
        if e.message =~ /undefined class\/module (.*)$/
          $1.constantize rescue return nil
        end
        return load(raw)
      end
    rescue Exception => e
      return nil
    end
  end

end