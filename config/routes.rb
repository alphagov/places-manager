Imminence::Application.routes.draw do
  resources :places, :only => :show
end
