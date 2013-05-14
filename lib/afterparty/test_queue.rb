require 'afterparty/redis_queue'
module Afterparty
  class TestRedisQueue < RedisQueue
    attr_accessor :completed_jobs
    
    def initialize redis=nil, opts={}, consumer_opts={}
      super
      @completed_jobs = []
      @exceptions = []
    end
    def handle_exception job, exception
      @exceptions << [job, exception]
    end
  end
end