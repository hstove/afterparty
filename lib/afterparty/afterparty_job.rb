require 'active_record'
require 'afterparty/queue_helpers'
class AfterpartyJob < ::ActiveRecord::Base
  # include Afterparty::QueueHelpers

  validates_presence_of :job_dump, :execute_at, :queue

  scope :incomplete, -> { where(completed: false).order("execute_at") }
  scope :valid, -> { incomplete.where(execute_at: 10.years.ago..DateTime.now) }
  scope :completed, -> { where(completed: true).order("execute_at desc") }

  def self.make_with_job job, queue=:default
    afterparty_job = AfterpartyJob.new
    afterparty_job.job_dump = job.to_yaml
    afterparty_job.execute_at = Afterparty.queue_time(job)
    afterparty_job.queue = queue
    afterparty_job.completed = false
    afterparty_job.save
    afterparty_job
  end

  def reify
    Afterparty.load(job_dump)
  end

  def execute
    if (j = reify)
      j.run
    end
  end
end