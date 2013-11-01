require 'iconv'
require 'date'

module Afterparty
  class JobContainer
    attr_accessor :job, :raw, :execute_at, :job_id, :queue_name

    #intialized from redis's WITHSCORES function
    def initialize _raw, timestamp
      @execute_at = Time.at(timestamp)
      begin
        @job = Afterparty.load(_raw)
        @job_id = job.afterparty_job_id if @job.respond_to? :afterparty_job_id
        @queue_name = job.afterparty_queue if @job.respond_to? :afterparty_queue
      rescue Exception => e
        @job = nil
      end
      @raw = _raw
      self
    end

    def job_class
      if @job
        @job.class
      else
        nil
      end
    end
  end
end