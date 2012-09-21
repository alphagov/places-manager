require 'business_support_data_importer'

namespace :business_support_data_importer do
  desc "Imports business support data from CSVs in data_dir."
  task :import, [:data_dir] => :environment do |t, args|
    BusinessSupportDataImporter.run(args[:data_dir])
  end
end
