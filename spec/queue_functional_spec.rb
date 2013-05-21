require 'spec_helper'
describe Afterparty::Queue do
  before do
    @q = Afterparty::Queue.new({sleep: 0.5})
  end

  after do
    @worker.stop
  end

  before :each do
    @worker = Afterparty::Worker.new({sleep: 0.5})
    @q.clear
    @job_time = (ENV['AFTERPARTY_JOB_TIME'] || 5).to_i
    @slow_job_time = (ENV['AFTERPARTY_SLOW_TIME'] || 7).to_i
  end

  it "pushes nil without errors" do
    @q.push(nil)
    @q.jobs.should eq([])
  end

  it "adds items to the queue" do
    lambda {
      @q.push(test_job)
    }.should change{ @q.total_jobs_count }.by(1)
  end

  it "executes the job" do
    job = TestJob.new
    @q.push(job)
    lambda {
      sleep(1)
      @worker.consume_next
    }.should change{ @q.total_jobs_count }.by(-1)
  end

  it "removes items from the queue after running them" do
    @q.push TestJob.new
    sleep(1)
    @worker.consume_next
    @q.jobs.size.should == 0
  end

  it "doesn't execute jobs that execute in a while" do
    job = TestJob.new
    job.execute_at = Time.now + 200
    @q.push job
    lambda {
      @worker.consume_next
    }.should change{ @q.total_jobs_count }.by(0)
  end

  it "waits the correct amount of time to execute a job" do
    job = TestJob.new
    job.execute_at = Time.now + 4
    @q.push(job)
    sleep(1)
    @q.jobs.size.should eq(1)
    chill(@slow_job_time)
    @worker.consume_next
    @q.jobs.size.should eq(0)
  end

  it "doesn't wait and execute the job synchronously when added" do
    job = test_job 100
    t = Time.now
    @q.push(job)
    (Time.now - t).should <= 1
  end

  it "executes jobs in the right order" do
    late_job = test_job 60*10
    early_job = test_job
    @q.push(late_job)
    @q.push(early_job)
    sleep(1)
    @worker.consume_next
    (jobs = @q.jobs).size.should eq(1)
    jobs[0].execute_at.should_not be(nil)
  end

  class ErrorJob
    attr_accessor :execute_at

    def run
      raise "hello"
    end
  end

  def complete
    @q.completed_jobs
  end

  def error_job later=nil
    job = ErrorJob.new
    job.execute_at = DateTime.now + later if later
    job
  end

  def chill seconds
    t = Time.now
    while Time.now < (t + seconds); end
  end

end