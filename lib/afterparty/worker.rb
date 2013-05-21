module Afterparty
  class Worker
    include QueueHelpers

    def consume
      @stopped = false
      # puts "starting worker with namespace [#{@options[:namespace]}]."
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
          puts "Executing job: #{job.id}"
          run job
        else
          sleep(@options[:sleep])
        end
      end
    end

    def stop
      @stopped = true
      @thread.join(0) if @thread
    end
  end
end