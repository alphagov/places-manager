FactoryBot.define do
  factory :service do
    name { "Important Government Service" }
    sequence(:slug) { |n| "important-government-service-#{n}" }
    source_of_data { "Somewhere beyond the sea" }
  end

  factory :place do
    transient do
      latitude { 53.105491 }
      longitude { -2.017493 }
    end

    service_slug { (Service.first || create(:service)).slug }
    data_set_version { Service.where(slug: service_slug).first.active_data_set_version }
    name { "CosaNostra Pizza #3569" }
    sequence(:address1) { |n| "#{n} Vista Road" }
    town { "Los Angeles" }
    postcode { "WC2B 6NH" }
    phone { "01234 567890" }
    location { Point.new(latitude: latitude, longitude: longitude) }
  end
end
