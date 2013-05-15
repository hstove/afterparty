module Afterparty
  class Worker
    include QueueHelpers

    def initialize options = {}
      @options = options
      @options[:adapter] ||= :redis
      @options[:namespace] ||= :default
      @options[:sleep] ||= 10
      @options[:logger] ||= Logger.new($stderr)
      self
    end

    def consume
      @stopped = false
      # puts "starting worker with namespace [#{@options[:namespace]}]."
      @thread = Thread.new {
        consume_sync
      }
      @thread
    end

    def consume_sync
      while !@stopped
        job = next_valid_job
        if job
          async_redis_call do
            @temp_namespace = "completed"
            redis_call :zadd, Time.now.to_i, Marshal.dump(job)
            redis_call :zrem, job
          end
          run job
        else
          sleep(@options[:sleep])
        end
      end
    end

    def stop
      @stopped = true
      @thread.join(0)
    end

    def run(job)
      fork do
        Marshal.load(job).run
      end
    rescue Exception => exception
      handle_exception job, exception
    end

    def handle_exception(job, exception)
      @options[:logger].error "Job Error: #{job.inspect}\n#{exception.message}\n#{exception.backtrace.join("\n")}"
    end
  end
end