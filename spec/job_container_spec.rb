require "spec_helper"

describe Afterparty::JobContainer do
  it "initializes correctly" do
    job = TestJob.new
    raw = YAML.dump(job)
    container = Afterparty::JobContainer.new raw, Time.now.to_i
    container.job.should be_a(TestJob)

    container.job_class.should eq(TestJob)
  end

  it "sets job to nil if an error is thrown in YAML.load" do
    Afterparty.stub(:load){ raise }
    job = TestJob.new
    raw = YAML.dump(job)
    container = Afterparty::JobContainer.new raw, Time.now.to_i
    container.job.should be_nil

    container.job_class.should be_nil
  end
end