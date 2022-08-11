FactoryBot.define do
  factory :user do
    sequence(:uid) { |n| "uid-#{n}" }
    sequence(:name) { |n| "Joe Bloggs #{n}" }
    sequence(:email) { |n| "joe#{n}@bloggs.com" }
    permissions { %w[signin] }
  end

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
    location { "POINT(#{longitude} #{latitude})" }
  end

  factory :place_archive do
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
    location { "POINT(#{longitude} #{latitude})" }
  end

  factory :data_set do
    service { create(:service) }

    after(:create) do |data_set, _evaluator|
      create_list(:place,
                  3,
                  data_set_version: data_set.version,
                  service_slug: data_set.service.slug)
    end
  end

  factory :archived_data_set, class: DataSet do
    service { create(:service) }
    state { "archived" }

    after(:create) do |data_set, _evaluator|
      create_list(:place_archive,
                  3,
                  data_set_version: data_set.version,
                  service_slug: data_set.service.slug)
    end
  end
end
