Imminence::Application.routes.draw do
  namespace :admin do
    resources :services do
      resources :data_sets do
        post :activate, :on => :member
      end
    end
    root :to => 'services#index'
  end

  resources :business_support_scheme, :only => :index
  resources :business_support_data, :only => :show
  resources :data_sets, :only => :show
  resources :places, :only => :show
  root :to => redirect('/admin')
end
