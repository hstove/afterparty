require 'spec_helper'
describe Afterparty::Queue do
  before do
    @q = Afterparty::Queue.new
  end

  before :each do
    @q.clear
  end

  it "should make a wrapper job when a job is pushed" do
    job = nil
    tester = test_job
    time = tester.execute_at = Time.now + 10.seconds
    -> {
      job = @q.push tester
    }.should change{ AfterpartyJob.count }.by(1)
    job.execute_at.utc.to_i.should == tester.execute_at.utc.to_i
  end

  it "should return a wrapper job for #push" do
    @q.push(test_job).class.should == AfterpartyJob
  end

  it "only returns valid jobs for #pop" do
    tester = test_job(60)
    @q.push tester
    tester2 = test_job
    tester2.name = "testable"
    @q.push tester2
    wrapper = @q.pop
    popped_job = wrapper.reify
    popped_job.name.should == tester2.name
    popped_job.execute_at.should == nil
  end

  it "supports namespacing" do
    queue = Afterparty::Queue.new namespace: "tester"
    queue.clear
    @q.clear
    tester = test_job
    tester.name = 'testy'
    job = queue.push(tester)
    job.queue.should == "tester"
    wrapper = queue.pop
    (inner = wrapper.reify).name.should == "testy"
    wrapper.queue.should == "tester"
  end
end