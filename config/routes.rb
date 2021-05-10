Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }
  devise_scope :user do
    root to: 'users/sessions#new'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get :guidelines, to: 'pages#guidelines'

  resources :dashboards
  resources :proposal_forms do
    member do
      post :clone
    end
    resources :proposal_fields do
    collection do
      get :field_type
    end
  end
  end
  resources :submit_proposals
  resources :proposal_types do
    member do
      get :location_based_fields
      get :proposal_type_locations
    end
  end
  resources :locations do
    member do
      get :proposal_types
    end
  end
end
