require "json"

# Shadow class to skip validation/callbacks for import
# rubocop:disable Rails/ApplicationRecord
class ImportedPlace < ActiveRecord::Base
  self.table_name = "places"
end
# rubocop:enable Rails/ApplicationRecord

namespace :import do
  desc "Import database from json files exported from mongo version"
  task from_export_files: [:environment] do
    ActiveRecord::Base.logger = nil
    total_time = 0

    User.delete_all
    Place.delete_all
    PlaceArchive.delete_all
    Service.delete_all
    DataSet.delete_all

    total_time += wrap_timer do
      puts("Importing User data")
      counter = 0
      CSV.foreach("tmp/exports/users.csv", headers: true) do |row|
        counter += 1
        row["permissions"] = JSON.parse(row["permissions"])
        row.delete("version")
        User.create!(row)
      rescue StandardError => e
        Rails.logger.warning("Failed to import user record #{row}: #{e.message}")
      end
      puts("Read #{counter} rows, imported #{User.count} users")
    end

    total_time += wrap_timer do
      puts("Importing Place data")
      counter = 0
      CSV.foreach("tmp/exports/places.csv", headers: true) do |row|
        counter += 1
        loc = JSON.parse(row["location"])
        if loc
          row["location"] = "POINT(#{loc['longitude']} #{loc['latitude']})"
        end
        row.delete("version")
        ImportedPlace.create!(row)
      rescue StandardError => e
        Rails.logger.warn("Failed to import place record #{row}: #{e.message}")
        Rails.logger.warn(e.backtrace.join("\n"))
        exit
      end
      puts("Read #{counter} rows, imported #{Place.count} Places")
    end

    total_time += wrap_timer do
      puts("Importing Place Archive data")
      counter = 0
      CSV.foreach("tmp/exports/place_archives.csv", headers: true) do |row|
        counter += 1
        loc = JSON.parse(row["location"])
        if loc
          row["location"] = "POINT(#{loc['longitude']} #{loc['latitude']})"
        end
        row.delete("version")
        PlaceArchive.create!(row)
      rescue StandardError => e
        Rails.logger.warn("Failed to import place archive record #{row}: #{e.message}")
      end
      puts("Read #{counter} rows, imported #{PlaceArchive.count} PlaceArchives")
    end

    total_time += wrap_timer do
      puts("Importing Service Structure data")
      Service.skip_callback(:validation, :before, :create_first_data_set)
      File.open("tmp/exports/services.json", "r") do |file|
        services = JSON.parse(file.read)
        services.each do |service_data|
          Service.transaction do
            service = Service.create!(service_data.except("data_sets", "_id"))
            service_data["data_sets"].each { |ds| service.data_sets.create(ds.except("places", "_id", "csv_data")) }
          end
        rescue StandardError => e
          Rails.logger.warn("Failed to import service record #{service_data['slug']}: #{e.message}")
        end
      end
      puts("Imported #{Service.count} services, #{DataSet.count} datasets")
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
