require 'csv'

class DataSetCsvPresenter
  attr_accessor :places

  def initialize(data_set)
    @places = data_set.places
  end

  def to_csv
    CSV.generate do |csv|
      to_array_for_csv.each do |row|
        csv << row
      end
    end
  end

  def to_array_for_csv
    [].tap do |csv|
      # We need to handle the location fields separately from the others.
      # location is a Point object (so doesn't serialize well to CSV by default)
      # and doesn't need to be exported because it's either overridden from the
      # override fields or set from MapIt's data using the postcode.
      # Also exclude the id from the CSV since it isn't needed by the import.

      # The fields called 'lng' and 'lat' are used as the override values by
      # Place.parameters_from_hash so we need to name them accordingly in the
      # CSV to avoid them being lost if a CSV is exported and then imported.
      non_location_headers = Place.attribute_names - ['_id', 'location', 'override_lng', 'override_lat']
      location_headers = ['lng', 'lat']
      csv << (non_location_headers + location_headers)
      places.each do |place|
        row = non_location_headers.collect { |h| place.send(h.to_sym) }
        if place.override_lat_lng?
          row << place.override_lng
          row << place.override_lat
        else
          2.times { |n| row << nil }
        end
        csv << row
      end
    end
  end
end
