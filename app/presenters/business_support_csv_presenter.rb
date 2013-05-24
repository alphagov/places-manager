require 'csv'

class BusinessSupportCSVPresenter
  def initialize(schemes)
    @schemes = schemes
  end

  def to_csv
    CSV.generate do |csv|
      csv << [
        "id","title", "start date", "end date",
        "business types","locations","purposes",
        "sectors","stages","support types",
      ]
      @schemes.each do |scheme|
        start_date = scheme.start_date.nil? ? "" : scheme.start_date.strftime("%d/%m/%Y")
        end_date = scheme.end_date.nil? ? "" : scheme.end_date.strftime("%d/%m/%Y")
        csv << [
          scheme.business_support_identifier, scheme.title, start_date, end_date,
          scheme.business_types.join(','), scheme.locations.join(','), scheme.purposes.join(','),
          scheme.sectors.join(','), scheme.stages.join(','), scheme.support_types.join(','),
        ]
      end
    end
  end
end
