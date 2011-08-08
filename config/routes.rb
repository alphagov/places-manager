Imminence::Application.routes.draw do
  namespace :admin do
    resources :services do
      resources :data_sets
    end
    root :to => 'services#index'
  end

  resources :places, :only => :show
end
