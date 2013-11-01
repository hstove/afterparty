require "spec_helper"

describe Afterparty do
  describe "#load" do
    it "should constantize any missing Classes while loading" do
      obj = TestJob.new
      dump = YAML.dump(obj)
      YAML.stub(:load) do
        YAML.unstub(:load)
        raise ArgumentError, "undefined class/module TestJob"
      end
      String.any_instance.should_receive(:constantize).once
      Afterparty.load(dump).should_not be_nil
    end

    it "returns nil when an exception is raised in YAML.load" do
      YAML.stub(:load){ raise Exception }
      Afterparty.load("anything").should be_nil
    end
  end

  describe "#job_valid?" do
    it "returns false unless job responds to #execute_at" do
      job = {}
      Afterparty.job_valid?(job).should be_false
    end

    it "returns false if #execute_at returns nil" do
      job = TestJob.new
      job.execute_at = nil
      Afterparty.job_valid?(job).should be_false
    end
  end
end