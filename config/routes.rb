Afterparty::Engine.routes.draw do
  get "/" => "afterparty/dashboard#index", as: :dashboard
  get "/run" => "afterparty/dashboard#run", as: :run_job
  get "/delete" => "afterparty/dashboard#destroy", as: :destroy_job
end