module Afterparty
  module QueueHelpers
    def [] namespace
      @temp_namespace = namespace
    end

    def redis_queue_name  
      puts (a = Afterparty.redis_queue_name(@temp_namespace || @options[:namespace]))
      a
    end

    def clear
      # redis_call :del
      AfterpartyJob.destroy_all
    end

    def redis_call command, *args
      result = Afterparty.redis_call (@temp_namespace || @options[:namespace]), command, *args
      @temp_namespace = nil
      result
    end

    def async_redis_call &block
      Afterparty.redis.pipelined &block
    end

    def jobs
      # _jobs = redis_call(:zrange, 0, -1)
      # _jobs.each_with_index do |job, i|
      #   _jobs[i] = Marshal.load(job)
      # end
      # _jobs
      AfterpartyJob.incomplete
    end

    def jobs_with_scores
      hash_from_scores(redis_call(:zrange, 0, -1, {withscores: true}))
    end

    def valid_jobs
      # redis_call :zrangebyscore, 0, Time.now.to_i
      AfterpartyJob.valid
    end

    def next_valid_job
      # valid_jobs.first
      AfterpartyJob.valid.first
    end

    def jobs_empty?
      # count = total_jobs_count
      # # ap count
      # count == 0
      AfterpartyJob.valid.empty?
    end

    def total_jobs_count
      # redis_call(:zcount, "-inf", "+inf")
      AfterpartyJob.incomplete.count
    end

    def redis
      @@redis
    end

    def last_completed
      # @temp_namespace = "completed"
      # redis_call(:zrange, -1, -1).first
      AfterpartyJob.completed.first
    end

    def completed
      # @temp_namespace = "completed"
      # redis_call(:zrange, -20, -1).reverse
      AfterpartyJob.completed
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

    def hash_from_scores raw
      arr = []
      raw.each do |group|
        arr << Afterparty::JobContainer.new(group[0], group[1])
      end
      arr
    end

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