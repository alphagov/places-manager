namespace :migrate do
  task :rename_business_support_types => :environment do
    types = Mongoid.database.collection('business_support_types')
    support_types = Mongoid.database.collection('business_support_support_types')

    if types
      support_types.drop if support_types

      types.rename('business_support_support_types')

      puts "Renamed collection 'business_support_types' to 'business_support_support_types'" if BusinessSupport::SupportType.count > 0
    end
  end
end
