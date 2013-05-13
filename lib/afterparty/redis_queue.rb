module Afterparty
  class RedisQueue
    attr_accessor :redis, :options, :temp_namespace, :consumer
    include Afterparty::QueueHelpers

    def initialize redis, options={}, consumer_options={}
      @consumer = ThreadedQueueConsumer.new(self, consumer_options).start
      @redis = redis
      @options = options
      @options[:namespace] ||= "default"
      @options[:sleep] ||= 5
      @mutex = Mutex.new
    end

    def push job
      @mutex.synchronize do
        return nil if job.nil?
        redis_call :zadd, queue_time(job), Marshal.dump(job)
        # ap "pushing job"
        # # ap jobs_with_scores
        # ap "valid_jobs in push: #{valid_jobs}"
        # ap "count: #{redis_call(:zcount, "-inf", "+inf")}"
        @consumer.start unless @consumer.thread.alive?
        @temp_namespace = nil
      end
    end

    def [] namespace
      @temp_namespace = namespace
    end

    def redis_queue_name
      "afterparty_#{@temp_namespace || @options[:namespace]}_queue"  
    end

    def pop
      @mutex.synchronize do
        while true do
          # ap "new pop loop"
          (_jobs = valid_jobs)
          # ap "count in pop: #{redis_call(:zcount, "-inf", "+inf")}"
          # ap "all jobs in pop: #{jobs}"
          if jobs_empty?
            # ap "empty, shutting down"
            @consumer.shutdown
          elsif !(_jobs).empty?
            # ap "got a job! #{_jobs[0]}"
            job_dump = _jobs[0]
            @redis.pipelined{ redis_call :zrem, job_dump }
            # ap "returning job"
            (j = Marshal.load(job_dump))
            return j
          end
          # ap "jobs left in the future. sleeping."
          sleep(@options[:sleep])
        end
      end
    end

    def clear
      redis_call :del
    end

    def redis_call command, *args
      result = @redis.send(command, redis_queue_name, *args)
      @temp_namespace = nil
      result
    end

    def jobs
      redis_call(:zrange, 0, -1).each {|job| job = Marshal.load(job)}
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
  end
end