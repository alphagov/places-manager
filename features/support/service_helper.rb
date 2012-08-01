module ServiceHelper
  def path_for_service(name)
    service = Service.where(name: name).first
    admin_service_path(service)
  end

  def csv_path_for_data(name)
    File.expand_path('../../support/data/' + name.parameterize + '.csv', __FILE__)
  end

  def upload_extra_data_set(service)
    service.data_sets.create!(
      data_file: File.open(csv_path_for_data(service.name))
    )
  end

  def create_service(name)
    s = Service.new(
      name: name,
      slug: name.parameterize,
      source_of_data: "Testing",
      data_file: File.open(csv_path_for_data(name))
    )
    s.save!
    s
  end
end

World(ServiceHelper)