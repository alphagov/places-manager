Imminence::Application.routes.draw do
  namespace :admin do
    resources :services do
      resources :data_sets do
        post :activate, :on => :member
        post :duplicate, :on => :member
        resources :places
      end
    end
    resources :business_support_schemes, :only => [:index, :new, :create, :edit, :update, :destroy]
    root :to => 'services#index'
  end

  get '/areas/:area_type', :to => 'areas#index', :constraints => { :area_type => /EUR|CTY|DIS|LBO/ }

  resources :business_support_schemes, :only => :index
  resources :data_sets, :only => :show
  resources :places, :only => :show
  root :to => redirect('/admin')
end
