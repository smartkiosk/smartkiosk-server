require 'sidekiq/web'

Rails.application.class.routes.draw do
  ActiveAdmin.routes(self)

  get '/'  => 'monitoring#index'

  devise_for :users, ActiveAdmin::Devise.config

  constraints lambda { |request|
    request.env["warden"].authenticate? and request.env['warden'].user.root?
  } do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount DAV4Rack::Handler.new(
    :root => Rails.root.join('public/builds').to_s,
    :root_uri_path => '/builds/',
    :resource_class => DAV4Rack::BuildResource,
    :log_to => Rails.root.join('log/webdav.log').to_s
  ) => '/builds/'

  resources :terminal_pings do
    collection do
      get :providers
    end
  end


  resources :collections
  resources :system_receipt_templates

  resources :terminal_orders do
    member do
      post :acknowledge
      post :complete
    end
  end

  resources :terminal_builds do
    member do
      get :hashes
    end
  end

  resources :payments do
    collection do
      get :limits
      post :offline
    end
    member do
      post :pay
      post :enqueue
    end
  end

  resources :session_records
end
