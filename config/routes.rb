Rails.application.routes.draw do

  # API routes
  namespace :api do
    resources :todos, only: [:index, :show, :update, :destroy, :create] do
      member do
        post :update_completed #/api/todos/:id/update_completed
      end
      collection do
        post :mark_done #/api/todos/mark_done
      end
    end
    
  end
end
