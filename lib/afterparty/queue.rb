require 'active_support/queueing'
require 'thread'
require 'delegate'
# require 'marshal'
module Afterparty
  class AfterQueue < ActiveSupport::Queue
    attr_accessor :last_job_time
    include Afterparty::QueueHelpers

    def push job
      return @que if job.nil?
      time = queue_time job
      job.define_singleton_method(:afterparty_queue_at) { time }
      job.define_singleton_method("<=>") { |job2| afterparty_queue_at <=> job2.afterparty_queue_at}
      @que.push(job)
      @que.sort!
    end
    alias :<< :push
    alias :enq :push

    def pop non_blocking=false
      # @mutex.synchronize do
        while true
          if @que.empty?
            return false
          elsif next_job_valid?
            return @que.shift
          end
        end
      # end
    end
    alias :shift :pop
    alias :deq :pop

    def next_job_valid?
      return false if @que.empty?
      job = @que[0]
      return job unless job_valid?(job)
      job.execute_at < Time.now
    end

  end
end