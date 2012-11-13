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

  resources :business_support_schemes, :only => :index
  resources :data_sets, :only => :show
  resources :places, :only => :show
  root :to => redirect('/admin')
end
