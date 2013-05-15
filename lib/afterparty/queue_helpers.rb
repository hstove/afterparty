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
      redis_call :del
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
      _jobs = redis_call(:zrange, 0, -1)
      _jobs.each_with_index do |job, i|
        _jobs[i] = Marshal.load(job)
      end
      _jobs
    end

    def jobs_with_scores
      hash_from_scores(redis_call(:zrange, 0, -1, {withscores: true}))
    end

    def valid_jobs
      redis_call :zrangebyscore, 0, Time.now.to_i
    end

    def next_valid_job
      valid_jobs.first
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

    def last_completed
      @temp_namespace = "completed"
      redis_call(:zrange, -1, -1).first
    end

    def completed
      @temp_namespace = "completed"
      redis_call(:zrange, -20, -1).reverse
    end

    def completed_with_scores
      @temp_namespace = "completed"
      hash_from_scores(redis_call(:zrange, -20, -1, withscores: true)).reverse
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