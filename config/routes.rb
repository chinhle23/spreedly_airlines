Rails.application.routes.draw do
  root 'flights#index'
  get '/result',  to: 'static_pages#result'
  get '/about',   to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/signup',  to: 'users#new'
  resources :users
  resources :flights do
    resources :transactions
  end
end
