FactoryGirl.define do
  
  factory :user do
    sequence(:uid) { |n| "uid-#{n}"}
    sequence(:name) { |n| "Joe Bloggs #{n}" }
    sequence(:email) { |n| "joe#{n}@bloggs.com" }
    if defined?(GDS::SSO::Config)
      # Grant permission to signin to the app using the gem
      permissions { Hash[GDS::SSO::Config.default_scope => ["signin"]] }
    end
  end
  
  factory :business_support_business_type do
    name "Charity"
    slug "charity"
  end
  factory :business_support_location do
    name "England"
    slug "england"
  end
  factory :business_support_scheme do
    title "EU Culture Programme"
    business_support_identifier "eu-culture-programme"
    priority 1
  end
  factory :business_support_sector do
    name "Tourism and travel"
    slug "tourism-and-travel"
  end
  factory :business_support_stage do
    name "Start-up"
    slug "start-up"
  end
  factory :business_support_type do
    name "Loan"
    slug "loan"
  end
end
