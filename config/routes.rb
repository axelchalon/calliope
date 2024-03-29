Rails.application.routes.draw do
  devise_for :players
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'pages#index'

  resources :players, only: [:show]

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'
end
