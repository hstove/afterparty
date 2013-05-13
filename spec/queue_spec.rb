require 'spec_helper'
require "active_support/log_subscriber/test_helper"
describe Afterparty::AfterQueue do
  before do
    @q = Afterparty::TestQueue.new
    @q.consumer.start
    @job = test_job
  end

  after :each do
    @q.drain
  end

  # after do
  #   @q.drain
  # end

  # it "pushes nil without errors" do
  #   @q.push(nil).should eq([])
  # end

  # it "executes the job" do
  #   ran = false
  #   job = TestJob.new { ran = true }
  #   @q.push(job)
  #   chill(1)
  #   ran.should eq(true)
  # end

  # it "removes items from the queue after running them" do
  #   @q.push @job
  #   chill(1)
  #   @q.jobs.should_not include(@job)
  # end

  # it "doesn't execute jobs that execute in a while" do
  #   ran = false
  #   job = TestJob.new { ran = true }
  #   job.execute_at = Time.now + 2
  #   @q.push job
  #   chill(1)
  #   ran.should eq(false)
  # end

  # it "waits the correct amount of time to execute a job" do
  #   ran = false
  #   job = TestJob.new { ran = true }
  #   job.execute_at = Time.now + 2
  #   @q.push(job)
  #   chill(15)
  #   ran.should eq(true)
  # end

  # it "doesn't execute the job synchronously when added" do
  #   job = TestJob.new
  #   job.execute_at = Time.now + 10
  #   t = Time.now
  #   @q.push(job)
  #   (Time.now - t).should <= 1
  # end

  # # it "sorts jobs correctly" do
  # #   late_job = test_job 4
  # #   @q.push late_job
  # #   early_job = test_job
  # #   @q.push(early_job).should eq([early_job, late_job])
  # #   early_job2 = test_job
  # #   @q.push(early_job2).jobs.should eq([early_job, early_job2, late_job])
  # # end

  # it "executes jobs in the right order" do
  #   ran = false
  #   late_ran = false
  #   late_job = TestJob.new { late_ran = true }
  #   late_job.execute_at = Time.now + 60*10
  #   early_job = TestJob.new { ran = true }
  #   @q.push(late_job)
  #   @q.push(early_job)
  #   chill(10)
  #   late_ran.should eq(false)
  #   ran.should eq(true)
  # end

  

end