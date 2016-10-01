Rails.application.routes.draw do

mount Ckeditor::Engine => '/ckeditor'
devise_for :users
as :user do
  get 'passwords/change_password' => 'devise/passwords#edit'
  put 'passwords' => 'devise/passwords#update'
end
#root "admin/dashboards#index"
root "admin/homes#index"
get 'back' => 'application#back'
namespace :admin do
  get 'bee_editor' => 'bee_editors#index'
  get '/mobile_applications/:mobile_application_id/success' => 'external_login#show'
  get '/events/:event_id/success' => 'user_registrations#show'
  get 'bee_editor/token' => 'bee_editors#token'
  get 'bee_editor/template' => 'bee_editors#template'
  # get '/check_email_existance' => 'users#check_email_existance'
  resources :time_zones
  resources :dashboards, :themes, :manage_users, :users, :roles, :homes, :smtp_settings
  resources :profiles, :manage_mobile_apps, :downloads, :external_login,:prohibited_accesses,:change_roles
  resources :licensees do
    resources :clients    
  end
  resources :clients do
    resources :users, :microsites
    resources :mobile_applications do
      resources :push_pem_files
    end
    resources :event_groups
    resources :events do
    end
  end
  resources :mobile_applications do
    resources :external_login
  end
  resources :events do
    resources :abouts, :event_highlights, :emergency_exits, :themes, :sequences,:leaderboards, :chats, :invitee_groups, :qr_code_scanners, :warehouse_timers
    resources :speakers, :attendees, :invitees, :agendas, :conversations, :users, :notifications
    resources :event_features, :menus, :faqs, :images, :highlight_images, :feedbacks, :sponsors, :qnas, :feedbacks
    resources :e_kits, :contacts, :panels, :imports, :user_registrations
    resources :groupings, :exhibitors, :manage_feature_status, :analytics, :registration_settings, :custom_page1s, :custom_page2s, :custom_page3s, :custom_page4s, :custom_page5s,:telecallers,:invitee_datas,:my_travels,:manage_invitee_fields
    
    resources :polls do
      resources :user_polls
    end

    resources :quizzes do
      resources :user_quizzes
    end

    # resources :invitee_datas do
    #   collection do
    #     post 'update_details'
    #   end
    # end

    resources :user_polls, :user_quizzes, :user_feedbacks, :likes, :comments

    resources :mobile_applications do
      resources :store_infos
    end  
    resources :awards do
      resources :winners 
    end
    resources :invitee_structures do
      resources :invitee_datas
    end
    resources :registrations

  end
  # resources :imports
end
  namespace :api do
    namespace :v1 do
      get 'tokens/destroy_token' => 'tokens#destroy_token', defaults: {format: 'json'}
      post 'tokens/get_key' => 'tokens#get_key'#, defaults: {format: 'json'}
      get 'tokens/check_token' => 'tokens#check_token', defaults: {format: 'json'}
      post 'tokens/user_sign_up' => 'tokens#user_sign_up', defaults: {format: 'json'}
      post 'tokens/facebook_authentication' => 'tokens#facebook_authentication', defaults: {format: 'json'}
      post 'tokens/twitter_authentication' => 'tokens#twitter_authentication', defaults: {format: 'json'}
      resources :events do 
        post 'delete_mobile_data', on: :collection 
        resources :chats do 
          post 'update_chat_read_status', on: :collection # method used for update msg read status for api.
        end  
      end
      resources :tokens, :social_media_authentications, :abouts, :agendas, :speakers, :invitees, :leaderboards, :attendees, :images, :ratings, defaults: {format: 'json'} 
      resources :faqs, :notifications, :conversations, :comments, :qnas, :polls,:invitee_trackings, defaults: {format: 'json'}
      resources :awards, :event_features, :sponsors, :likes, :notes, :user_feedbacks,:e_kits, :mobile_applications, :passwords, :my_travels, defaults: {format: 'json'}
    end
  end
end