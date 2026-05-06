Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[create]
      resource :session, only: %i[create destroy]
      resources :passwords, param: :token, only: %i[create update]
      resource :me, only: %i[show], controller: :me
    end
  end

  # Health check for load balancers and uptime monitors.
  get "up" => "rails/health#show", as: :rails_health_check
end
