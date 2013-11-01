require 'spec_helper'
describe Afterparty::QueueHelpers do
  before do
    @q = Afterparty::Queue.new
  end

  before :each do
    AfterpartyJob.destroy_all
  end

  it "destroys all jobs with with #clear" do
    AfterpartyJob.make_with_job test_job(10)
    AfterpartyJob.count.should == 1
    @q.clear
    AfterpartyJob.count.should == 0
  end

  it "returns incomplete jobs on #jobs" do
    a = AfterpartyJob.make_with_job test_job(20)
    b = AfterpartyJob.make_with_job test_job
    @q.jobs.to_a.should == [b, a]
  end

  it "doesn't return incomplete jobs on #valid_jobs" do
    a = AfterpartyJob.make_with_job test_job(20)
    b = AfterpartyJob.make_with_job test_job
    @q.valid_jobs.to_a.should == [b]
  end

  it "returns the next valid job" do
    a = AfterpartyJob.make_with_job test_job(20)
    b = AfterpartyJob.make_with_job test_job
    c = AfterpartyJob.make_with_job test_job
    @q.next_valid_job.should == b
  end

  it "correctly returns whether there are no valid jobs" do
    AfterpartyJob.make_with_job test_job(20)
    @q.jobs_empty?.should == true
  end

  it "correctly returns the total number of incomplete jobs" do
    AfterpartyJob.make_with_job test_job(20)
    @q.total_jobs_count.should == 1
  end

  it "configures dashboard login successfully" do
    expect{ @q.authenticate("user", "pass") }.to raise_exception
    @q.config_login do |username, password|
      username == "user" && password == "pass"
    end
    @q.authenticate("user","pass").should == true
    @q.authenticate("userbad","pass").should == false
    @q.authenticate("user","passbad").should == false
  end

  it "saves errors if a job can't reify" do
    job = AfterpartyJob.make_with_job test_job
    job.stub(:reify) { nil }
    @q.run job
    job.has_error.should be_true
    job.error_message.should eq("Error marshaling job.")
  end

  it "handles exceptions when running a job" do
    job = AfterpartyJob.make_with_job test_job
    job.stub(:reify).and_raise(Exception, "message")
    @q.should_receive(:handle_exception)
    @q.run job
  end

  it "saves error data about a job when handling exceptions" do
    job = AfterpartyJob.make_with_job test_job
    job.stub(:reify).and_raise(Exception, "message")
    @q.options[:logger].should_receive(:error)
    @q.run job
    job.completed.should be_true
    job.completed_at.should be < DateTime.now
    job.has_error.should be_true
    job.error_message.should eq("message")
    job.error_backtrace.should_not be_nil
  end

  it "returns the last completed job" do
    job = AfterpartyJob.make_with_job test_job
    job.completed = true
    job.save
    @q.last_completed.should eq(job)
    @q.completed.should eq([job])
  end
end