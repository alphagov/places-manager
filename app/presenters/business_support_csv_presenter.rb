require 'csv'

class BusinessSupportCSVPresenter
  def initialize(schemes)
    @schemes = schemes
  end

  def to_csv
    CSV.generate do |csv|
      csv << [
        "id","title",
        "business types","locations","purposes",
        "sectors","stages","support types",
      ]
      @schemes.each do |scheme|
        csv << [
          scheme.business_support_identifier, scheme.title,
          scheme.business_types.join(','), scheme.locations.join(','), scheme.purposes.join(','),
          scheme.sectors.join(','), scheme.stages.join(','), scheme.support_types.join(','),
        ]
      end
    end
  end
end
