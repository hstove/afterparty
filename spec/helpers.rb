module Afterparty
  module QueueTestHelpers

    def test_job later=false, &block
      job = block ? TestJob.new(block) : TestJob.new
      job.execute_at = Time.now + (later) if later
      @block = block
      job
    end

    def chill seconds
      t = Time.now
      while Time.now < (t + seconds); end
    end
  end
end

class TestJob
  attr_accessor :execute_at, :name

  def initialize &block
    @block = block
  end

  def run
    @block.call if @block
  end
end