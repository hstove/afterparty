module Afterparty
  class Queue
    attr_accessor :options, :temp_namespace, :login_block
    include Afterparty::QueueHelpers

    def push job
      return nil if job.nil?
      AfterpartyJob.make_with_job job, @options[:namespace]
    end
    alias :<< :push
    alias :eng :push

    def pop
      while true do
        unless (_job = next_valid_job).nil?
          _job.save
          return _job
        end
        sleep(@options[:sleep])
      end
    end
  end
end