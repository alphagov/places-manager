FactoryGirl.define do
  factory :business_support_business_type, :class => BusinessSupport::BusinessType do
    name "Charity"
    slug "charity"
  end
  factory :business_support_business_size, :class => BusinessSupport::BusinessSize do
    name "Under 10"
    slug "under-10"
  end
  factory :business_support_location, :class => BusinessSupport::Location do
    name "England"
    slug "england"
  end
  factory :business_support_purpose, :class => BusinessSupport::Purpose do
    name "Setting up your business"
    slug "setting-up-your-business"
  end
  factory :business_support_scheme do
    title "EU Culture Programme"
    business_support_identifier "eu-culture-programme"
    priority 1
  end
  factory :business_support_sector, :class => BusinessSupport::Sector do
    name "Tourism and travel"
    slug "tourism-and-travel"
  end
  factory :business_support_stage, :class => BusinessSupport::Stage do
    name "Start-up"
    slug "start-up"
  end
  factory :business_support_type, :class => BusinessSupport::SupportType do
    name "Loan"
    slug "loan"
  end
end
