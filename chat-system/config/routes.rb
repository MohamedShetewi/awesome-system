Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # application routes
  get "application/:app_id" => "application#show"
  post "application" => "application#create"
  
  get "application/:app_id/chat/:chat_id" => "chat#show"
  post "application/:app_id/chat" => "chat#create"

  post "application/:app_id/chat/:chat_id/message" => "message#create"
  get "application/:app_id/chat/:chat_id/message/:message_id" => "message#show"
end
