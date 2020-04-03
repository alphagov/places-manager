require "gds_api/test_helpers/mapit"

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
    File.expand_path("../../support/data/" + name.parameterize + ".csv", __FILE__)
  end

  def upload_extra_data_set(service)
    service.data_sets.create!(
      data_file: File.open(csv_path_for_data(service.name))
    )
    run_all_delayed_jobs
  end

  def create_service(params)
    mapit_knows_nothing_about_any_postcodes

    params = service_defaults.merge(params)

    s = Service.new(
      name: params[:name],
      slug: params[:slug],
      source_of_data: params[:source_of_data],
      location_match_type: location_match_type(params[:location_match_type]),
      local_authority_hierarchy_match_type: local_authority_hierarchy_match_type(params[:local_authority_hierarchy_match_type]),
      data_file: File.open(params[:csv_path])
    )
    s.save!
    run_all_delayed_jobs
    s
  end

  def location_match_type(select_option_name)
    case select_option_name
    when "Nearest"
      "nearest"
    when "Local authority"
      "local_authority"
    end
  end

  def local_authority_hierarchy_match_type(select_option_name)
    case select_option_name
    when "District"
      "district"
    when "County"
      "county"
    end
  end

  def fill_in_form_with(params)
    mapit_knows_nothing_about_any_postcodes

    params = service_defaults.merge(params)

    fill_in "Name", with: params[:name]
    fill_in "Slug", with: params[:slug]
    fill_in "Source of data", with: (params[:source_of_data])

    select (params[:location_match_type]), from: "Location match type"
    if params[:location_match_type] == "Local authority"
      select (params[:local_authority_hierarchy_match_type]), from: "Local authority hierarchy match type"
    end

    attach_file "Data file", params[:csv_path]
    click_button "Create Service"
  end

  def service_defaults
    {
      name: "Register Offices",
      slug: "register-offices",
      source_of_data: "test source of data",
      location_match_type: "Local authority",
      local_authority_hierarchy_match_type: "District",
      csv_path: csv_path_for_data("Register Offices")
    }
  end

  def fill_in_place_form_with(name)
    fill_in "Name", with: name
    click_button "Update Place"
  end

  def upload_csv_data(csv_data)
    csv_file = Tempfile.new("exported_data_set.csv")
    begin
      csv_file.write(csv_data)
      csv_file.rewind

      within "#new-data" do
        attach_file "Data file", csv_file.path
        click_button "Create Data set"
      end
    ensure
      csv_file.close
      csv_file.unlink
    end
  end

  def mapit_knows_nothing_about_any_postcodes
    stub_request(:get, %r{#{GdsApi::TestHelpers::Mapit::MAPIT_ENDPOINT}/postcode/[^\.]+\.json})
      .to_return(:body => { "code" => 404, "error" => "No Postcode matches the given query." }.to_json, :status => 404)
  end
end

World(ServiceHelper)
