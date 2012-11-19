FactoryGirl.define do
  factory :service do
    name "Important Government Service"
    sequence(:slug) {|n| "important-government-service-#{n}"}
    source_of_data "Somewhere beyond the sea"
  end

  factory :place do
    name "CosaNostra Pizza #3569"
    sequence(:address1) {|n| "#{n} Vista Road" }
    town "Los Angeles"
    postcode "WC2B 6NH"
    phone "01234 567890"
    lat 53.105491
    lng -2.017493
  end
end
