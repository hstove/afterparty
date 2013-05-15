Afterparty::Engine.routes.draw do
  get "/" => "afterparty/dashboard#index", as: :dashboard
  get "/run" => "afterparty/dashboard#run", as: :run_job
  get "/delete" => "afterparty/dashboard#run", as: :delete_job
end

Rails.application.routes.draw do
  mount Afterparty::Engine, at: "afterparty", as: "afterparty_engine"
end