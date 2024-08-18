require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :user, skip: [:registrations]
  root to: 'home#index'
  
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :dashboard, only: [:index] do
    collection do

    end
  end

  resources :orders

  resources :users
  
  resources :profiles

  resources :attempts, only: [:index] do
    collection do
      get :reprocess
      get :verify_attempts
    end
  end
end
