queue = Rails.configuration.queue = Afterparty::Queue.new

queue.config_login do |username, password|
  # change this to something more secure!
  user == "admin" && password == "password"
end