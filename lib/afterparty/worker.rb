module Afterparty
  class Worker
    include QueueHelpers

    def consume
      @stopped = false
      @thread = Thread.new {
        consume_sync
      }
      @thread
    end

    def consume_next
      if (job = next_valid_job)
        run job
      end
    end

    def consume_sync
      while !@stopped
        job = next_valid_job
        if job
          t = Time.now
          logger.info "Executing job #{job.id}." if job.respond_to? :id
          run job
          logger.info "Completed job #{job.id if job.respond_to? :id}."
          log_time_metrics t
        else
          sleep(@options[:sleep])
        end
      end
    end

    def stop
      @stopped = true
      @thread.join(0) if @thread
    end

    private

    def log_time_metrics old_time
      time_elapsed = Time.now - old_time
      jobs_per_s = 1.0 / time_elapsed
      logger.info " #{time_elapsed.round(2)} seconds. #{jobs_per_s} jobs/s."
    end
  end
end