require 'rails/generators'
class AfterpartyGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def install
    copy_file "jobs_migration.rb", "db/migrate/#{Time.now.strftime('%Y%m%d%H%M%S')}_create_afterparty_jobs.rb"
    copy_file "initializer.rb", "config/initializers/afterparty.rb"
    route "mount Afterparty::Engine, at: \"afterparty\", as: \"afterparty_engine\""
  end
end