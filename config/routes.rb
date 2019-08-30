Rails.application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations', sessions:  'sessions' }

  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
    get '/users/sign_up' => 'devise/registration#new'
    get '/users/edit' => 'devise/registration#edit'
  end
  resources :pool, only: [:index] do
    collection do
      get 'api'
    end
  end
  resources :user, only: [:index] do
    member do
      post 'horse_race_object_click'
      post 'disable_by_admin'
      post 'enable_by_admin'
      post 'continue_membership_by_admin'
      post 'clear_membership_by_admin'
      post 'process_payment'
    end
    collection do
      post 'hook'
      post 'free_subscription_plan'
    end
  end
  resources :race_condition_details
  resources :rail_detail_ranks
  resources :score_report, only: [:index]
  resources :tips_report, only: [:index]
  resources :bets_report, only: [:index,:show] do
    collection do
      get 'graph'
      get 'api'
      get 'category'
      get 'by_week'
      get 'by_week_special'
    end
  end
  resources :class_report, only: [:index]
  resources :class_sectional, only: [:index]
  resources :outlier, only: [:index]
  resources :scorecard, only: [:index,:show] do
    collection do
      get :date
      get :total
      get :graph
      get :api
    end
  end
  resources :summary, only: [:show]
  resources :race_classes
  resources :race, only: [:show] do
    collection do
      get :cup
    end
  end
  resources :horse, only: [:show]
  resources :jockey, only: [:show]
  resources :trainer, only: [:show]
  resources :date, only: [:show,:index]
  resources :score_way, only: [:index]
  resources :posts
  resources :post_comments
  get '/all-posts', to: 'post_comments#index'
  resources :magic_ball, only: [:index,:show] do
    collection do
      get :api
      get :tool
    end
  end
  resources :forecast, only: [:index] do
    collection do
      get :ajax
    end
  end
  #resources :home, only: [:index]
  resources :gorilla_bets, only: [:index] do
    collection do
      get :by_week_special
    end
  end
  resources :upcoming_feature_races, only: [:index]
  resources :login, only: [:index]
  resources :main, only: [:index]
  resources :facebook, only: [:index]
  resources :public_info, only: [] do
    collection do
      get :'privacy_policy'
      get :'terms_and_conditions'
      get :'dutch_betting'
      get :'welcome_page'
    end
  end

  get 'dailytips', controller: :daily_tips, action: :index
  resources :daily_tips, only: [] do
    collection do
      get :races
      get :tracks
      get :tips
    end
  end

  resources :plans do
    resources :subscriptions do
      member do
        get :cancel_subscription
      end
      collection do
        get :free_trial
      end
    end
  end
  post :store_billing_detail, to: 'subscriptions#store_billing_detail'

  mount StripeEvent::Engine, at: '/stripe_events'
  root to: 'daily_tips#index'
end
