# Afterparty

A Rails 4 compatible queue with support for executing jobs in the future and serialization with Redis.

## Installation

Add this line to your application's Gemfile:

~~~Ruby
gem 'afterparty'
~~~

If you intend to use Rails 4, you must use the **jobs** branch.

~~~Ruby
gem 'rails', '4.0.0.rc1', github: "rails/rails", branch: "jobs", tag: "v4.0.0.rc1"
~~~

If you want to use it with Rails 3.2, use the [rails-queue](https://github.com/probablywrong/rails-queue) gem.

~~~Ruby
gem 'rails-queue'
~~~

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install afterparty

In your desired application environment, like `application.rb`:

~~~Ruby
Rails.queue = Afterparty::RedisQueue.new
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






## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
