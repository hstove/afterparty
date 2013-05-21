module Afterparty
  module QueueHelpers

    def initialize options = {}
      @options = options
      @options[:namespace] ||= :default
      @options[:sleep] ||= 10
      @options[:logger] ||= Logger.new($stderr)
      self
    end

    def [] namespace
      @temp_namespace = namespace
    end

    def clear
      # redis_call :del
      AfterpartyJob.namespaced(@options[:namespace]).destroy_all
    end

    def jobs
      AfterpartyJob.namespaced(@options[:namespace]).incomplete
    end

    def jobs_with_scores
      hash_from_scores(redis_call(:zrange, 0, -1, {withscores: true}))
    end

    def valid_jobs
      AfterpartyJob.namespaced(@options[:namespace]).valid
    end

    def next_valid_job
      AfterpartyJob.namespaced(@options[:namespace]).valid.first
    end

    def jobs_empty?
      AfterpartyJob.namespaced(@options[:namespace]).valid.empty?
    end

    def total_jobs_count
      AfterpartyJob.namespaced(@options[:namespace]).incomplete.count
    end

    def last_completed
      AfterpartyJob.namespaced(@options[:namespace]).completed.first
    end

    def completed
      AfterpartyJob.namespaced(@options[:namespace]).completed
    end

    def completed_with_scores
      @temp_namespace = "completed"
      hash_from_scores(redis_call(:zrange, -20, -1, withscores: true)).reverse
    end

    def run(job)
      real_job = job.reify
      if real_job
        job.execute
      else
        job.has_error = true
        job.error_message = "Error marshaling job."
      end
      job.completed = true
      job.completed_at = DateTime.now
      job.save
    rescue Exception => exception
      handle_exception job, exception
    end

    def handle_exception(job, exception)
      job.completed = true
      job.completed_at = DateTime.now
      job.has_error = true
      job.error_message = exception.message
      job.error_backtrace = exception.backtrace.join("\n")
      job.save
      logger_message = "Job Error: #{job.inspect}\n#{exception.message}"
      logger_message << "\n#{exception.backtrace.join("\n")}"
      @options[:logger].error logger_message
    end

    # &block takes a 'username' and 'password'
    # argument. return true or false
    def config_login &block
      @login_block = block
    end

    def authenticate username, password
      raise 'Must set queue.config_login to use dashboard' if @login_block.nil?
      @login_block.call(username, password)
    end


    private

    # returns true if job has an :execute_at value
    def job_valid? job
      job.respond_to?(:execute_at) && !job.execute_at.nil?
    end

    # return timestamp of :execute_at or current time
    def queue_time job
      time = job_valid?(job) ? job.execute_at.to_i : Time.now.to_i
    end
  end
end