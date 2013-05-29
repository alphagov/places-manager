namespace :migrate do
  task :rename_business_support_types => :environment do
    # This collection is created by loading the environment as mongoid
    # attempts to build collections for all models. Safe to drop if it's empty.
    types = Mongoid.database.collection('business_support_types')
    support_types = Mongoid.database.collection('business_support_support_types')

    support_types.drop if types and support_types
    
    types.rename('business_support_support_types')

    puts "Renamed collection 'business_support_types' to 'business_support_support_types'" if BusinessSupport::SupportType.count > 0
  end
end
