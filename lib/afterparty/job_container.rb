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
        ap "Error during load: #{e.message}"
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

    def raw_string
      ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
      ic.iconv(@raw.dup + ' ')[0..-2]
    end
  end
end