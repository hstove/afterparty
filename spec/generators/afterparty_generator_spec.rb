require 'spec_helper'
describe :afterparty do
  within_source_root do
    FileUtils.mkdir_p "config"
    FileUtils.touch "config/routes.rb"
  end
  it "works" do
    subject.should generate(:copy_file, "jobs_migration.rb")
    subject.should generate("config/initializers/afterparty.rb") do |content|
      content.should include("Afterparty::Queue.new")
      content.should include("queue.config_login do |username, password|")
    end
    subject.should generate(:route, "mount Afterparty::Engine, at: \"afterparty\", as: \"afterparty_engine\"")
  end
end