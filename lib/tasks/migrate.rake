namespace :migrate do
  desc "Move places out of services.data_sets and into their own collection"
  task :extract_places => :environment do
    Service.all.each do |service|
      service.data_sets.each do |set|
        set['places'].each do |place|
          Place.create_from_hash(set, place.except('_id'))
        end

        set['places'] = nil
        set.save
      end
    end
  end
end