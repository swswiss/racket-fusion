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
      post 'create_brackets'
      get 'beginner_schedule'
      get 'medium_schedule'
      get 'medium_plus_schedule'
      get 'expert_schedule'
      post 'create_team'
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

  # resources :registrations do
  #   collection do
  #     post 'invite'
  #   end
  #   member do
  #     post 'accept'
  #     post 'decline'
  #   end
  # end

  resources :tweets, only: [:create, :destroy] do
    resources :likes, only: [:create, :destroy]
    resources :bookmarks, only: [:create, :destroy]
  end

  
  get :dashboard, to: "dashboard#index"
  get :tournaments, to: "tournaments#index"

  resources :usernames, only: [:new, :update, :index, :destroy] do
    patch 'update_status', on: :member
  end
  resources :users, only: [:index, :show] do

    post 'create_promotion', on: :collection
    
    post 'create_points', on: :collection
    get 'beginner', on: :collection
    get 'medium', on: :collection
    get 'medium_plus', on: :collection
    get 'expert', on: :collection
  end

  resources :groups, except: [:show] do
    member do
      post 'update_scores_group'
      get 'print_groups_medium'
      get 'csv_groups_medium'
    end
    collection do
      post 'add_match_to_group'
    end
  end

  resources :rounds, except: [:show] do
    member do
      post 'update_scores_group'
      get 'print_rounds_medium'
    end
  end

  resources :matches, only: [:update, :destroy, :new]
  resources :leagues
  resources :statistics do
    get 'duel', on: :collection
    get 'headtohead', on: :collection
  end
  resources :invitations
  post '/receive_data', to: 'invitations#receive_data'
  resources :blogs

  resources :blogvisitors do
    get 'index', on: :collection
  end
end
