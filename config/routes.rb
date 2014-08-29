Imminence::Application.routes.draw do
  namespace :admin do
    resources :services do
      resources :data_sets do
        post :activate, :on => :member
        post :duplicate, :on => :member
        resources :places
      end
    end
    root :to => 'services#index'
  end

  get '/areas/:area_type', :to => 'areas#index', :constraints => { :area_type => /EUR|CTY|DIS|LBO/ }
  get '/areas/:postcode', :to => 'areas#search', :constraints => { :postcode => /[\w% ]+/ }

  resources :data_sets, :only => :show
  resources :places, :only => :show
  root :to => redirect('/admin')

  mount GovukAdminTemplate::Engine, at: "/style-guide"
end
