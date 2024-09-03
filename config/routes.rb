require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :user, skip: [:registrations]
  root to: 'home#index'
  
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :dashboard, only: [:index] do
    collection do
      get :to_do
    end
  end

  resources :orders do
    collection do
      get :tiny_orders
      get :search_contacts
    end
  end

  resources :users
  
  resources :profiles

  resources :contacts

  resources :products

  resources :order_payment_types

  resources :attempts, only: [:index] do
    collection do
      get :reprocess
      get :verify_attempts
    end
  end
end
