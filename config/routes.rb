Rails.application.routes.draw do
  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response

  namespace :admin do
    resources :services do
      resources :data_sets, except: %i[index destroy] do
        post :activate, on: :member
        post :duplicate, on: :member
        resources :places, except: %i[index show]
      end
    end
    root to: "services#index"
  end

  resources :places, only: :show
  root to: redirect("/admin")

  mount GovukAdminTemplate::Engine, at: "/style-guide"
end
