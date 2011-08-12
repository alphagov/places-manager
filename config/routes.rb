Imminence::Application.routes.draw do
  namespace :admin do
    resources :services do
      resources :data_sets do
        post :activate, :on => :member
      end
    end
    root :to => 'services#index'
  end

  resources :places, :only => :show
end
