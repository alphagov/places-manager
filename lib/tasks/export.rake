require "csv"

namespace :export do
  desc "Export database as json so it can be imported into relational database"
  task as_files: [:environment] do
    total_time = 0

    Dir.mkdir("tmp/exports") unless Dir.exist?("tmp/exports")

    total_time += wrap_timer do
      puts("Writing User data to CSV file")
      CSV.open("tmp/exports/users.csv", "w") do |csv|
        fields = User.first.fields.keys.excluding("_id")
        csv << fields
        User.all.find_each do |user|
          row = []
          fields.each do |f|
            row <<  if f == "permissions"
                      user[f].to_json
                    else
                      user[f]
                    end
          end
          csv << row
        end
      end
    end

    total_time += wrap_timer do
      puts("Writing Place data to CSV file")
      CSV.open("tmp/exports/places.csv", "w") do |csv|
        fields = Place.first.fields.keys.excluding("_id")
        csv << fields
        Place.all.find_each do |place|
          row = []
          fields.each do |f|
            row <<  if f == "location"
                      place[f].to_json
                    else
                      place[f]
                    end
          end
          csv << row
        end
      end
    end

    total_time += wrap_timer do
      puts("Writing Service Structure data to JSON file")
      File.open("tmp/exports/services.json", "w") do |file|
        file.write(Service.all.to_json)
      end
    end

    total_time += wrap_timer do
      puts("Writing PlaceArchive data to CSV file")
      CSV.open("tmp/exports/place_archives.csv", "w") do |csv|
        fields = PlaceArchive.first.fields.keys.excluding("_id")
        csv << fields
        PlaceArchive.all.find_each do |place|
          row = []
          fields.each do |f|
            row <<  if f == "location"
                      place[f].to_json
                    else
                      place[f]
                    end
          end
          csv << row
        end
      end
    end

    puts("Total Time: #{total_time} seconds")
  end
end

def wrap_timer
  start_t = Time.zone.now
  yield
  duration = Time.zone.now - start_t

  puts("Took #{duration} seconds")

  duration
end
