Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do  
    get '/users/sign_out' => 'devise/sessions#destroy'     
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "home#index"

  resources :tournaments, only: [:create, :show, :destroy, :update] do
    member do
      post 'change_status_opened'
      post 'change_status_closed'
      post 'create_groups'
      get 'beginner_schedule'
      get 'medium_schedule'
      get 'medium_plus_schedule'
      get 'expert_schedule'
    end
    post 'create_level_two', on: :member, to: 'registrations#create_level_two'
    post 'create_level_three', on: :member, to: 'registrations#create_level_three'
    post 'create_level_four', on: :member, to: 'registrations#create_level_four'

    resources :registrations, only: [:create, :destroy] do
      member do
        delete 'destroy_level_two'
        delete 'destroy_level_three'
        delete 'destroy_level_four'
        post 'modify_waitlisted_users'
      end
    end
  end

  resources :tweets, only: [:create, :destroy] do
    resources :likes, only: [:create, :destroy]
    resources :bookmarks, only: [:create, :destroy]
  end

  
  get :dashboard, to: "dashboard#index"
  get :tournaments, to: "tournaments#index"

  resources :usernames, only: [:new, :update, :index]
  resources :users, only: [:index]

  resources :groups, except: [:show] do
    member do
      post 'update_scores_group'
    end
  end
  resources :matches, only: [:update]
end
