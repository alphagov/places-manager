require 'csv'
require 'uri'
Encoding.default_external = 'UTF-8'

namespace :import do
  
  desc "cache the list of registry offices to disk"
  CachedUrlTask.new do |t|
    t.cache_file = 'db/sources/registry_offices.csv'
    t.url = "http://local.direct.gov.uk/Data/local_register_offices.csv"
  end
  
  task :registry_offices => [:environment, 'db/sources/registry_offices.csv'] do
    service = Service.find_or_create_by(name: 'Registry Offices', slug: 'registry-offices')
    data_set = service.data_sets.any? ? service.data_sets.first : service.data_sets.build

    raw_data = File.read('db/sources/registry_offices.csv').encode("UTF-8")
    CSV.parse(raw_data, :headers => true) do |row|
      begin
        data_set.places.create(
          name: row['title'],
          address: [row['Address Line 1'], row['Address Line 2'], row['Address Line 3']].compact.join(", "),
          town: row['Town/City'],
          postcode: row['Postcode'],
          url: row['URL']
        )
      rescue => e
        puts e.message
      end
    end
    
    user = User.first || User.create(name: 'Bot', uid: 'bot')
    user.activate_data_set(data_set)
  end
end