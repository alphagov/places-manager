class BusinessSupportType
  include Mongoid::Document
  
  field :name, type: String
  field :slug, type: String
end

namespace :migrate do
  task :populate_support_types => :environment do
    BusinessSupportType.all.each do |t|
      support_type = BusinessSupport::SupportType.find_or_initialize_by(slug: t.slug, name: t.name)
      puts "Migrated #{support_type.name}" if support_type.save
    end
  end
end
