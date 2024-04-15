require "csv"
require "places_manager/file_verifier"

class Admin::DataSetsController < InheritedResources::Base
  include Admin::Defaults
  include Admin::FileUpload
  include Admin::Permissions

  before_action :set_breadcrumbs

  actions :all, except: %i[new destroy]
  belongs_to :service

  before_action :check_permission!

  def show
    @only_errors = params[:only_errors] == "true"
    super
  end

  def create
    prohibit_non_csv_uploads
    create! do |_success, failure|
      failure.html { render "new" }
    end
    flash[:success] = "Data Set #{resource.version} created"
  end

  def activate
    if resource.activate
      flash[:success] = "Data Set #{resource.version} successfully activated"

      if resource.latest_data_set?
        resource.service.schedule_archive_places
        resource.service.schedule_delete_historic_records
      end
    else
      flash[:danger] = "Couldn't activate data set"
    end
    redirect_to resource_path(resource)
  end

  def fix_geoencode_errors
    FixGeoencodeErrorsWorker.perform_async(service.id.to_s, resource.version)
    flash[:info] = "Attempting to fix geocode errors - refresh page to see progress"
    redirect_to resource_path(resource)
  end

protected

  def set_breadcrumbs
    @breadcrumbs = [
      { title: "Services", url: "/" },
      { title: service.name, url: admin_service_path(service) },
      { title: "Data sets", url: admin_service_data_sets_path(service) },
    ]

    case params[:action]
    when "show"
      @breadcrumbs << { title: "Version #{resource.version}", url: resource_path(resource) }
    when "new"
      @breadcrumbs << { title: "New" }
    end
  end

  def missing_csv
    @form_errors = [{ id: "data_set[data_file]", href: "#data-set-data-file-field", text: "You must specify a datafile to upload." }]
    render "new", status: :unprocessable_entity
  end

  def bad_encoding
    @form_errors = [{ id: "data_set[data_file]", href: "data-set-data-file-field", text: "Could not process CSV file. Please check the format." }]
    render "new", status: :unprocessable_entity
  end

  def bad_csv
    @form_errors = [{ id: "data_set[data_file]", href: "#data-set-data-file-field", text: "Could not process CSV file. Please check the format." }]
    render "new", status: :unprocessable_entity
  end

  def data_set_params
    params
      .require(:data_set)
      .permit(
        :data_file,
        :change_notes,
      )
  end

  def service
    # This is ActiveAdmin's accessor for the service object. We are calling it
    # directly rather than using the @ accessor.
    parent
  end

  def check_permission!
    return if permission_for_service?(service)

    raise PermissionDeniedException, "Sorry, you do not have permission to edit datasets for this service."
  end
end
