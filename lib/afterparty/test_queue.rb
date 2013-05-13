require 'afterparty/queue'
module Afterparty
  module TestQueueMethods
    def initialize opts={}
      super
      @exceptions = []
    end

    def handle_exception job, exception
      @exceptions << [job, exception]
    end
  end

  class TestQueue < AfterQueue
    include TestQueueMethods

    def initialize opts={}, consumer_opts={}
      super
      @exceptions = []
    end

    def jobs
      @que.dup
    end
  end

  class TestRedisQueue < RedisQueue
    attr_accessor :completed_jobs
    
    def initialize redis=nil, opts={}, consumer_opts={}
      super
      @completed_jobs = []
      @exceptions = []
    end
  end
end