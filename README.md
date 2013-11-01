# Afterparty

[![Build Status](https://travis-ci.org/hstove/afterparty.png?branch=master)](https://travis-ci.org/hstove/afterparty)
[![Code Climate](https://codeclimate.com/github/hstove/afterparty.png)](https://codeclimate.com/github/hstove/afterparty)
[![Coverage Status](https://coveralls.io/repos/hstove/afterparty/badge.png)](https://coveralls.io/r/hstove/afterparty)

A Rails 3 & 4 compatible queue with support for executing jobs in the future and persistence with ActiveRecord.

## Installation

Add this line to your application's Gemfile:

~~~Ruby
gem 'afterparty'
~~~

And then execute:

    $ bundle
    $ rails g afterparty
    $ rake db:migrate

This will create an initializer in `config/initializers/afterparty.rb`. It initializes a queue at
`Rails.configuration.queue` for you to pass jobs to.

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
Rails.configuration.queue << Job.new
~~~

If your job responds to an `execute_at` method, the queue will wait to process that job until the specified time.

### Running jobs

You can start a worker in a separate process for executing jobs by calling `rake jobs:work`.

### Helper jobs

Afterparty provides helper job wrappers for executing arbitrary methods or mailers.

~~~Ruby
# pass an object, method, and arguments 

mailer_job = Afterparty::MailerJob.new UserMailer, :welcome, @user
mailer_job.execute_at = Time.now + 20.minutes
Rails.configuration.queue << mailer_job

job = Afterparty::BasicJob.new @user, :reset_password
Rails.configuration.queue << job
~~~

### Dashboard

![dashboard screenshot](https://raw.github.com/hstove/afterparty/master/docs/dashboard.png)

This gem provides a handy dashboard for inspecting, debugging, and re-running jobs.

Visit [http://localhost:3000/afterparty/](http://localhost:3000/afterparty/) and login with
`admin` and `password`. You can change the authentication strategy in `config/initializers/afterparty.rb` to something like this:

~~~Ruby
Rails.configuration.queue.config_login do |username, password|
  user = User.authenticate(username, password)
  !user.nil? && user.is_admin?
end
~~~

### Unicorn configuration

If you're using Unicorn as your application server, you can run a worker thread asynchronously by adding a few lines to your `unicorn.rb`:

~~~Ruby

@jobs_pid = nil

before_fork do |server, worker|
  @jobs_pid ||= spawn("bundle exec rake jobs:work")

  # ... the rest of your configuration
~~~

This has the advantage of, for example, staying within Heroku's free tier by not running a worker dyno.

## TODO

* Finish namespacing support by adding documentation and allowing a worker rake task to pull jobs from a custom (or all) queues.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add a test in `spec/redis_queue_spec.rb`
4. Make sure tests pass when you run `rake`
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
