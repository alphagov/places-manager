Rails.application.routes.draw do
  namespace :admin do
    resources :services do
      resources :data_sets, except: [:index, :destroy] do
        post :activate, :on => :member
        post :duplicate, :on => :member
        resources :places, except: [:index, :show]
      end
    end
    root :to => 'services#index'
  end

  get '/areas/:area_type', :to => 'areas#index', :constraints => { :area_type => /EUR|CTY|DIS|LBO|LGD|MTD|UTA/ }
  get '/areas/:postcode', :to => 'areas#search'

  resources :places, :only => :show
  root :to => redirect('/admin')

  mount GovukAdminTemplate::Engine, at: "/style-guide"
end
