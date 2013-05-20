namespace :jobs do
  require 'mail'

  desc "Start a new worker"
  task work: :environment do
    worker = Afterparty::Worker.new
    worker.consume_sync
  end

  # desc "Clear all jobs"
  # task clear: :environment do
  #   Rails.configuration.queue.clear
  # end

  desc "List Jobs"
  task list: :environment do
    jobs = Rails.configuration.queue.jobs
    puts "#{jobs.size} total jobs."
    jobs.each do |time, job|
      puts time
      puts job
    end
  end
end

