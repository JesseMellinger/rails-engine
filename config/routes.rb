Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      get 'items/find', to: 'items#find'
      get 'items/find_all', to: 'items#find_all'
      resources :items, except: [:new, :edit] do
        resources :merchants, only: [:index], module: :items
      end
      get 'merchants/find', to: 'merchants#find'
      get 'merchants/find_all', to: 'merchants#find_all'
      resources :merchants, except: [:new, :edit] do
        resources :items, only: [:index], module: :merchants
      end
    end
  end
end
