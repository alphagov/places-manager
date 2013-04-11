require 'csv'

class BusinessSupportCSVPresenter
  def initialize(schemes)
    @schemes = schemes
  end

  def to_csv
    CSV.generate do |csv|
      csv << [
        "id","title",
        #"web_url","organiser","short description","body",
        #"eligibility","evaluation","additional information","contact details",
        #"max employees","min value","max value","continuation link",
        "business types","locations","purposes",
        "sectors","stages","support types",
      ]
      @schemes.each do |scheme|
        csv << [
          scheme.business_support_identifier, scheme.title,
          # TODO: populate these fields from ContentAPI
          #nil, nil, nil, nil,
          #nil, nil, nil, nil,
          #nil, nil, nil, nil,
          scheme.business_types.join(','), scheme.locations.join(','), scheme.purposes.join(','),
          scheme.sectors.join(','), scheme.stages.join(','), scheme.support_types.join(','),
        ]
      end
    end
  end
end
