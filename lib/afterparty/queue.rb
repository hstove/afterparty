module Afterparty
  class Queue
    attr_accessor :options, :temp_namespace, :login_block
    include Afterparty::QueueHelpers

    def initialize options={}, consumer_options={}
      # @consumer = ThreadedQueueConsumer.new(self, consumer_options).start
      @options = options
      @options[:namespace] ||= "default"
      # Afterparty.add_queue @options[:namespace]
      @options[:sleep] ||= 5
      @mutex = Mutex.new
      @options[:logger] ||= Logger.new($stderr)
    end

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
            ap "poppin job"
            _job.completed = true
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