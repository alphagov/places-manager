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
      headers = ['name', 'address1', 'address2', 'town', 'postcode', 'access_notes', 'general_notes', 'url', 'lat', 'lng', 'phone', 'fax', 'text_phone']
      csv << headers
      places.each do |place|
        csv << headers.collect { |h| place.send(h.to_sym) }
      end
    end
  end
end
