require 'spec_helper'
describe AfterpartyJob do
  before :each do
    AfterpartyJob.destroy_all
  end

  it "makes a job correctly" do
    tester = test_job
    tester.execute_at = Time.now + 10
    job = AfterpartyJob.make_with_job tester
    job.reload
    (reloaded = job.reify).class.should == tester.class
    reloaded.execute_at.utc.should == tester.execute_at.utc
    job.execute_at.should == reloaded.execute_at
  end

end