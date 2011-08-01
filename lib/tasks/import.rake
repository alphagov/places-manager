namespace :import do
  task :registry_offices => :environment do
    require 'csv'
    require 'open-uri'
    blah = open("http://local.direct.gov.uk/Data/local_register_offices.csv").read
    data = CSV.parse(blah, :headers => true) do |row|
      Place.create(
        :name => row['title'],
        :address => [row['Address Line 1'], row['Address Line 2'], row['Address Line 3']].compact.join(", "),
        :town => row['Town/City'],
        :postcode => row['Postcode'],
        :url => row['URL']
      )
    end
  end
end