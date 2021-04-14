Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }
  devise_scope :user do
    root to: 'users/sessions#new'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get :guidelines, to: 'pages#guidelines'

  resources :dashboards
  resources :submit_proposals
  resources :proposal_types do
    member do 
      get :location_based_fields
    end
  end
  resources :locations do
    member do
      get :proposal_types
    end
  end
end
