Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do  
    get '/users/sign_out' => 'devise/sessions#destroy'     
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "home#index"

  resources :tournaments, only: [:create, :show] do
    member do
      post 'change_status_opened'
      post 'change_status_closed'
    end
    post 'create_level_two', on: :member, to: 'registrations#create_level_two'
    post 'create_level_three', on: :member, to: 'registrations#create_level_three'
    post 'create_level_four', on: :member, to: 'registrations#create_level_four'

    resources :registrations, only: [:create, :destroy] do
      member do
        delete 'destroy_level_two'
        delete 'destroy_level_three'
        delete 'destroy_level_four'
      end
    end
  end

  resources :tweets, only: [:create, :destroy] do
    resources :likes, only: [:create, :destroy]
    resources :bookmarks, only: [:create, :destroy]
  end

  
  get :dashboard, to: "dashboard#index"
  get :tournaments, to: "tournaments#index"

  resources :usernames, only: [:new, :update]
end
