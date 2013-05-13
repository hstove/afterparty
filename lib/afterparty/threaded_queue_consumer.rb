module Afterparty  

  # inspired by the rails 4 implementation: 
  # https://github.com/rails/rails/blob/jobs/activesupport/lib/active_support/queueing.rb

  # The threaded consumer will run jobs in a background thread in
  # development mode or in a VM where running jobs on a thread in
  # production mode makes sense.
  #
  # When the process exits, the consumer pushes a nil onto the
  # queue and joins the thread, which will ensure that all jobs
  # are executed before the process finally dies.
  class ThreadedQueueConsumer
    attr_accessor :logger, :thread

    def initialize(queue, options = {})
      @queue = queue
      @logger = options[:logger]
      @fallback_logger = Logger.new($stderr)
    end

    def start
      @thread = Thread.new { consume }
      self
    end

    def shutdown
      @queue.push nil
      @thread.join
    end

    def drain
      while job = @queue.pop(true)
        job.run
      end
    rescue ThreadError
    end

    def consume
      while job = @queue.pop
        if @queue.respond_to? :completed_jobs
          @queue.completed_jobs << job
        end
        run job
      end
    end

    def run(job)
      job.run
    rescue Exception => exception
      handle_exception job, exception
    end

    def handle_exception(job, exception)
      (logger || @fallback_logger).error "Job Error: #{job.inspect}\n#{exception.message}\n#{exception.backtrace.join("\n")}"
    end
  end
end