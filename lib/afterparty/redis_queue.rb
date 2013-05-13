module Afterparty
  class RedisQueue
    attr_accessor :redis, :options, :temp_namespace, :consumer
    include Afterparty::QueueHelpers

    def initialize redis=nil, options={}, consumer_options={}
      @consumer = ThreadedQueueConsumer.new(self, consumer_options).start
      @redis = redis || Redis.new
      @options = options
      @options[:namespace] ||= "default"
      @options[:sleep] ||= 5
      @mutex = Mutex.new
    end

    def push job
      @mutex.synchronize do
        return nil if job.nil?
        async_redis_call{ redis_call :zadd, queue_time(job), Marshal.dump(job) }
        @consumer.start unless @consumer.thread.alive?
        @temp_namespace = nil
      end
    end
    alias :<< :push
    alias :eng :push

    def pop
      @mutex.synchronize do
        while true do
          if jobs_empty?
            @consumer.shutdown
          elsif !(_jobs = valid_jobs).empty?
            job_dump = _jobs[0]
            async_redis_call do
              redis_call :zrem, job_dump
              @temp_namespace = "completed"
              redis_call :zadd, Time.now.to_i, job_dump
            end
            return Marshal.load(job_dump)
          end
          sleep(@options[:sleep])
        end
      end
    end
  end
end