module ServiceHelper
  def path_for_service(name)
    service = Service.where(name: name).first
    admin_service_path(service)
  end

  def path_for_latest_data_set_for_service(name)
    service = Service.where(name: name).first
    data_set = service.latest_data_set
    admin_service_data_set_path(service, data_set)
  end

  def path_for_active_data_set_for_service(name)
    service = Service.where(name: name).first
    data_set = service.active_data_set
    admin_service_data_set_path(service, data_set)
  end

  def path_for_data_set_version_for_service(name, version)
    service = Service.where(name: name).first
    data_set = service.data_sets(version: version).first
    admin_service_data_set_path(service, data_set)
  end

  def csv_path_for_data(name)
    File.expand_path('../../support/data/' + name.parameterize + '.csv', __FILE__)
  end

  def upload_extra_data_set(service)
    service.data_sets.create!(
      data_file: File.open(csv_path_for_data(service.name))
    )
    run_all_delayed_jobs
  end

  def create_service(name)
    s = Service.new(
      name: name,
      slug: name.parameterize,
      source_of_data: "Testing",
      data_file: File.open(csv_path_for_data(name))
    )
    s.save!
    run_all_delayed_jobs
    s
  end

  def fill_in_form_with(name, csv_path)
    fill_in 'Name', with: name
    fill_in 'Slug', with: name.parameterize
    fill_in 'Source of data', with: 'Testing'
    attach_file 'Data file', csv_path
    click_button 'Create Service'
  end

  def fill_in_place_form_with(name)
    fill_in 'Name', with: name
    click_button "Update Place"
  end
end

World(ServiceHelper)
