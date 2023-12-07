Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do  
    get '/users/sign_out' => 'devise/sessions#destroy'     
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "home#index"

  resources :tournaments, only: :create do
    resources :registrations, only: [:create, :destroy]
  end

  resources :tweets, only: :create do
    resources :likes, only: [:create, :destroy]
    resources :bookmarks, only: [:create, :destroy]
  end

  
  get :dashboard, to: "dashboard#index"
  get :tournaments, to: "tournaments#index"

  resources :usernames, only: [:new, :update]
end
