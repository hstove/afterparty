require "spec_helper"

describe Afterparty::Worker do
  let(:worker) { Afterparty::Worker.new({sleep: 0.25}) }
  after do
    worker.stop
  end

  describe "consume" do
    it "calls a new thread" do
      Thread.should_receive(:new).once
      worker.consume
    end

    it "calls consume_sync on itself" do
      worker.should_receive(:consume_sync).once
      worker.consume
      sleep 0.25
    end
  end

  describe "consume_sync" do
    it "runs the next_valid_job" do
      worker.instance_variable_set "@stopped", false
      job = TestJob.new
      worker.stub(:next_valid_job) {
        worker.unstub(:next_valid_job)
        worker.instance_variable_set "@stopped", true
        job
      }
      worker.should_receive(:run).with(job)
      worker.consume_sync
      worker.stop
    end

    it "sleeps if there are no valid jobs" do
      worker.instance_variable_set "@stopped", false
      worker.stub(:next_valid_job) {
        worker.unstub(:next_valid_job)
        worker.instance_variable_set "@stopped", true
        nil
      }
      worker.should_receive(:sleep).with(0.25)
      worker.consume_sync
      worker.stop
    end
  end
end