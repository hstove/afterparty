module Afterparty
  class RedisQueue
    attr_accessor :redis, :options, :temp_namespace, :consumer
    include Afterparty::QueueHelpers

    def initialize options={}, consumer_options={}
      # @consumer = ThreadedQueueConsumer.new(self, consumer_options).start
      @options = options
      @options[:namespace] ||= "default"
      Afterparty.add_queue @options[:namespace]
      @options[:sleep] ||= 5
      @mutex = Mutex.new
    end

    def push job
      @mutex.synchronize do
        return nil if job.nil?
        job.class.module_eval do
          attr_accessor :afterparty_job_id, :afterparty_queue
        end
        queue_name = @temp_namespace || @options[:namespace]
        job.afterparty_queue = queue_name
        job.afterparty_job_id = Afterparty.next_job_id queue_name
        async_redis_call{ redis_call :zadd, queue_time(job), Marshal.dump(job) }
        @temp_namespace = nil
      end
    end
    alias :<< :push
    alias :eng :push

    def pop
      @mutex.synchronize do
        while true do
          if !(_jobs = valid_jobs).empty?
            job_dump = _jobs[0]
            async_redis_call do
              redis_call :zrem, job_dump
              @temp_namespace = "completed"
              redis_call :zadd, Time.now.to_i, job_dump
            end
            begin
              return Marshal.load(job_dump)
            rescue ArgumentException => e
              puts "You encountered an argument exception while deserializing a job."
              puts "Message: #{e.message}"
              raise e
            end
          end
          sleep(@options[:sleep])
        end
      end
    end
  end

  class TestRedisQueue < RedisQueue
    attr_accessor :completed_jobs
    
    def initialize opts={}, consumer_opts={}
      super
      @completed_jobs = []
      @exceptions = []
    end
    def handle_exception job, exception
      @exceptions << [job, exception]
    end
  end
end