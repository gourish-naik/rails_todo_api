Rails.application.routes.draw do

  # API routes
  namespace :api do
    resources :todo, only: [:show, :update, :destroy], controller: 'todo_details'
    resources :todos do
      member do
        patch 'update_completed'
      end
    end
    
  end
end
