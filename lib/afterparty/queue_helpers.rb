module Afterparty
  module QueueHelpers
    def job_valid? job
      job.respond_to?(:execute_at) && !job.execute_at.nil?
    end
    def queue_time job
      time = job_valid?(job) ? job.execute_at.to_i : Time.now.to_i
    end
  end
end