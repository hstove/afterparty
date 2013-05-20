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
end