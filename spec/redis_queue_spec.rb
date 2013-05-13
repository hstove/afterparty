require 'spec_helper'
describe Afterparty::RedisQueue do
  before do
    require 'open-uri'
    uri = URI.parse("redis://localhost:6379")
    redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    @q = Afterparty::TestRedisQueue.new(redis, {sleep: 0.5})
  end

  before :each do
    @q.completed_jobs.clear
    @q.clear
  end

  it "pushes nil without errors" do
    @q.push(nil)
    @q.jobs.should eq([])
  end

  it "adds items to the queue" do
    @q.push(test_job)
    @q.total_jobs_count.should eq(1)
  end

  it "executes the job" do
    job = TestJob.new
    @q.push(job)
    complete.size.should eq(0)
    chill(1)
    complete.size.should eq(1)
  end

  it "removes items from the queue after running them" do
    @q.push TestJob.new
    chill(1)
    @q.jobs.should_not include(@job)
  end

  it "doesn't execute jobs that execute in a while" do
    job = TestJob.new
    job.execute_at = Time.now + 2
    @q.push job
    chill(1)
    complete.size.should eq(0)
  end

  it "waits the correct amount of time to execute a job" do
    job = TestJob.new
    job.execute_at = Time.now + 2
    @q.push(job)
    chill(7)
    complete.size.should eq(1)
  end

  it "doesn't execute the job synchronously when added" do
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
    chill(1)
    complete.size.should eq(1)
    complete[0].execute_at.should be(nil)
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
    job.execute_at = Time.now + later if later
    job
  end

  def chill seconds
    t = Time.now
    while Time.now < (t + seconds); end
  end

end