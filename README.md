# Afterparty

A Rails 4 compatible queue with support for executing jobs in the future and serialization with Redis.

## Installation

Make sure you've installed [redis](http://redis.io) on your machine.

Add this line to your application's Gemfile:

~~~Ruby
gem 'afterparty'
~~~

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install afterparty

In your desired application environment, like `application.rb`:

~~~Ruby
config.queue = Afterparty::RedisQueue.new
~~~

## Usage

A `job` is a ruby object with a `run` method.

~~~Ruby
class Job
  def run
    puts "Hello!"
  end
end
~~~

Then add it to the queue at any time.

~~~Ruby
Rails.queue << Job.new
~~~

## Configuration


  





## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add a test in `spec/redis_queue_spec.rb`
4. Make sure tests pass when you run `rake`
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
