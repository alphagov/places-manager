namespace :migrate do
  desc "Move places out of services.data_sets and into their own collection"
  task :extract_places => :environment do
    Rails.logger = Logger.new(STDOUT)

    Service.all.each do |service|
      service.data_sets.each do |set|
        puts "Processing #{service.name}, version #{set.version}"

        unless set["places"]
          puts "No places found: continuing"
          next
        end

        places = set['places']

        # Tidy up the bizarre appearance of 4-dimensional coordinates
        places.each do |place|
          location = place["location"]
          if location.is_a?(Array) && location.size > 2
            if location.size == 4 && location[0,2] == location[2,2]
              # The same place, repeated. For some reason
              place['location'] = location[0,2]
            else
              puts "Inconsistent location: #{location.inspect}"
              place['location'] = []
            end
          end
        end

        results = places.map { |place|
          # Bypass validation because we have old, crap data that we don't want
          # to have to deal with right now
          Place.create_from_hash(set, place.except('_id'), validate: false)
        }

        success_count = results.count(&:persisted?)

        expected_count = set['places'].length
        if expected_count != success_count
          puts "Some data hasn't transferred properly " +
               "(#{success_count} of #{expected_count})"
          results.reject(&:persisted?).each do |failure|
            puts failure.errors.inspect
          end
        else
          puts "Transferred #{success_count} places successfully"
        end

        set['places'] = nil
        set.save
      end
    end
  end
end
