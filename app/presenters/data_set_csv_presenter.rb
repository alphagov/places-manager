require "csv"

class DataSetCsvPresenter
  def initialize(data_set)
    @data_set = data_set
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
      csv << all_headers
      @data_set.places.each do |place|
        csv << build_row(place)
      end
    end
  end

private

  # We need to handle the location fields separately from the others.
  # location is a Point object (so doesn't serialize well to CSV by default)
  # and doesn't need to be exported because it's either overridden from the
  # override fields or set from MapIt's data using the postcode.
  # Also exclude the id from the CSV since it isn't needed by the import.
  def non_location_headers
    @non_location_headers ||= Place.attribute_names - %w[_id location override_lng override_lat id created_at updated_at]
  end

  # The fields called 'lng' and 'lat' are used as the override values by
  # Place.parameters_from_hash so we need to name them accordingly in the
  # CSV to avoid them being lost if a CSV is exported and then imported.
  def location_headers
    %w[lng lat]
  end

  def all_headers
    non_location_headers + location_headers
  end

  def build_row(place)
    non_location_fields(place) + location_fields(place)
  end

  def non_location_fields(place)
    non_location_headers.map { |header| place.send(header.to_sym) }
  end

  def location_fields(place)
    if place.override_lat_lng?
      [place.override_lng, place.override_lat]
    else
      [nil, nil]
    end
  end
end
