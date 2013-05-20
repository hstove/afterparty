require 'spec_helper'
describe :afterparty do
  it "works" do
    subject.should generate(:copy_file, "jobs_migration.rb")
    subject.should generate("config/initializers/afterparty.rb") do |content|
      content.should include("Afterparty::Queue.new")
      content.should include("queue.config_login do |username, password|")
    end
  end
end