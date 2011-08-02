Imminence::Application.routes.draw do
  namespace :admin do
    resources :services
    root :to => 'services#index'
  end

  resources :places, :only => :show
end
