module Afterparty
  class Queue
    attr_accessor :options, :temp_namespace, :login_block
    include Afterparty::QueueHelpers

    def push job
      # @mutex.synchronize do
        return nil if job.nil?
        queue_name = @temp_namespace || @options[:namespace]
        AfterpartyJob.make_with_job job, queue_name
      # end
    end
    alias :<< :push
    alias :eng :push

    def pop
      # @mutex.synchronize do
        while true do
          unless (_job = AfterpartyJob.valid.first).nil?
            _job.save
            return _job
          end
          sleep(@options[:sleep])
        end
      # end
    end
  end
  
  class TestQueue < Queue
    attr_accessor :completed_jobs
    
    def initialize opts={}
      super
      @completed_jobs = []
      @exceptions = []
    end
    def handle_exception job, exception
      @exceptions << [job, exception]
    end
  end
end