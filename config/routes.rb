Rails.application.routes.draw do
  namespace :admin do
    resources :services do
      resources :data_sets, except: %i[index destroy] do
        post :activate, :on => :member
        post :duplicate, :on => :member
        resources :places, except: %i[index show]
      end
    end
    root to: "services#index"
  end

  # This list should stay in sync with Publisher's Area::AREA_TYPES
  # https://github.com/alphagov/publisher/blob/master/app/models/area.rb#L7-L10
  get "/areas/:area_type", to: "areas#index", constraints: { area_type: /EUR|CTY|DIS|LBO|LGD|MTD|UTA|COI/ }
  get "/areas/:postcode", to: "areas#search", constraints: { postcode: /[\w% ]+/ }

  resources :places, :only => :show
  root to: redirect("/admin")

  mount GovukAdminTemplate::Engine, at: "/style-guide"
end
