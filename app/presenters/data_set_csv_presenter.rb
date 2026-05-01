require "csv"

class DataSetCsvPresenter
  COLUMN_NAMES = %w[service_slug data_set_version name source_address address1 address2 town postcode access_notes general_notes url email phone fax text_phone geocode_error gss lng lat map_marker_colour map_marker_symbol].freeze

  def initialize(data_set)
    @data_set = data_set
  end

  def to_csv
    CSV.generate do |csv|
      csv << COLUMN_NAMES

      @data_set.places.each do |place|
        csv << build_row(place)
      end
    end
  end

private

  def translate_attribute(name)
    case name
    when "lat"
      :override_lat
    when "lng"
      :override_lng
    else
      name.to_sym
    end
  end

  def build_row(place)
    COLUMN_NAMES.map { |header| place.send(translate_attribute(header)) }
  end
end
