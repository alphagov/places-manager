Rails.application.routes.draw do
  mount GovukPublishingComponents::Engine, at: "/component-guide" if Rails.env.development?

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::ActiveRecord,
  )

  namespace :admin do
    resources :services do
      resources :data_sets, except: %i[update destroy] do
        post :activate, on: :member
        post :fix_geoencode_errors, on: :member
        resources :places, only: :show
      end
    end
    root to: "services#index"
  end

  resources :places, only: :show
  root to: redirect("/admin")
end
