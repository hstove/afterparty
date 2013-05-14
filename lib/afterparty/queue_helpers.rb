module Afterparty
  module QueueHelpers
    def [] namespace
      @temp_namespace = namespace
    end

    def redis_queue_name
      "afterparty_#{@temp_namespace || @options[:namespace]}_queue"  
    end

    def clear
      redis_call :del
    end

    def redis_call command, *args
      result = Afterparty.redis.send(command, redis_queue_name, *args)
      @temp_namespace = nil
      result
    end

    def async_redis_call &block
      Afterparty.redis.pipelined &block
    end

    def jobs
      _jobs = redis_call(:zrange, 0, -1)
      _jobs.each_with_index do |job, i|
        _jobs[i] = Marshal.load(job)
      end
      _jobs
    end

    def jobs_with_scores
      redis_call :zrange, 0, -1, {withscores: true}
    end

    def valid_jobs
      redis_call :zrangebyscore, 0, Time.now.to_i
    end

    def jobs_empty?
      count = total_jobs_count
      # ap count
      count == 0
    end

    def total_jobs_count
      redis_call(:zcount, "-inf", "+inf")
    end

    def redis
      @@redis
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