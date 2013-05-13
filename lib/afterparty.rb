require 'logger'
require 'afterparty/queue_helpers'
require 'afterparty/redis_queue'
Dir[File.expand_path('../afterparty/*', __FILE__)].each { |f| require f }


