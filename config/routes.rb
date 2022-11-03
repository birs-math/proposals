Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions',
                                    registrations: 'users/registrations' }
  devise_scope :user do
    root to: 'users/sessions#new'
    delete 'sign_out', to: 'users/sessions#destroy'
    get 'sign_out', to: 'users/sessions#destroy'
  end

  get :guidelines, to: 'pages#guidelines'
  resources :feedbacks, path: :feedback do
    member do
      patch :add_reply
    end
  end
  get 'dashboards', to: 'proposal_types#index'

  resources :submitted_proposals do
    collection do
      get :download_csv_organizers_and_participants
      get :download_csv
      post :proposals_booklet
      get :download_booklet
      post :edit_flow
      post :revise_proposal_editflow
      post :approve_decline_proposals
      post :table_of_content
      post :import_reviews
      post :reviews_booklet
      get :download_review_booklet
      get :reviews_excel_booklet
      post :proposal_outcome_location
    end
    member do
      post :update_status
      post :update_location
      post :staff_discussion
      post :send_emails
      get :reviews
    end
  end

  resources :reviews, only: [] do
    member do
      delete :remove_file
      post :add_file
    end
  end

  resources :schedules do
    collection do
      get :download_csv
      get :new_schedule_run
      post :run_hmc_program
      post :abort_run
      get :optimized_schedule
      post :export_scheduled_proposals
    end
  end
  delete '/schedule_runs/:id', to: 'schedule_runs#destroy', as: 'destroy_schedule_runs'

  get :invite, to: 'invites#show'
  get 'invites/show_invite_modal/:id', to: 'invites#show_invite_modal', as: 'show_invite_modal'
  get 'cancelled' => 'invites#cancelled'
  post 'cancel' => 'invites#cancel'
  post 'cancel_confirmed_invite' => 'invites#cancel_confirmed_invite'

  resources :proposals do
    post :latex, to: 'proposals#latex_input'
    member do
      get :versions
      get :proposal_version
      get :rendered_proposal, to: 'proposals#latex_output'
      get :rendered_field, to: 'proposals#latex_field'
      patch :ranking
      get :locations
      post :upload_file
      post :remove_file
    end

    resources :invites, except: [:show] do
      member do
        post :inviter_response
        post :invite_reminder
        post :invite_email
        post :new_invite
      end
      collection do
        get :thanks
      end
    end
  end

  resources :survey do
    collection do
      get :survey_questionnaire
      get :faqs
      post :submit_survey
      get :submit_survey_without_response
      post :pre_load_survey_questionnaire
    end
  end

  resources :people, path: :person
  get 'person/show_person_modal/:id', to: 'people#show_person_modal', as: 'show_person_modal'
  patch 'person/update_lead_organizer/:id', to: 'people#update_lead_organizer', as: 'update_lead_organizer'

  resources :submit_proposals do
    collection do
      get :thanks
      post :invitation_template
    end
  end
  resources :proposal_types do
    resources :proposal_forms do
      member do
        post :clone
        delete :proposal_field
        get :proposal_field_edit
      end
      resources :proposal_fields do
        collection do
          post :latex_text
        end
      end
    end
    member do
      get :location_based_fields
      get :proposal_type_locations
    end
  end
  resources :locations do
    member do
      get :proposal_types
    end
    collection do
      post :weeks_exclude_dates
    end
  end
  resources :page_contents

  resources :faqs do
    member do
      patch :move
    end
  end

  get 'profile/' => 'profile#edit'
  patch 'update' => 'profile#update'
  post 'demographic_data' => 'profile#demographic_data'

  resources :roles do
    member do
      post :new_user
      post :new_role
      post :remove_role
    end
  end

  resources :subject_categories do
    resources :subjects
    resources :ams_subjects
  end

  resources :emails do
    collection do
      patch :email_template
      post :email_types
    end
  end

  resources :email_templates

  # Serve websocket cable requests in-process (passenger runs separate process)
  mount ActionCable.server => '/cable'

  Rails.application.routes.draw do
    if Rails.env.test?
      namespace :test do
        resource :session, only: %i[create]
      end
    end
  end
end
