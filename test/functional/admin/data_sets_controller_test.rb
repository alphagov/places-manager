require "test_helper"
require "gds_api/test_helpers/mapit"

class Admin::DataSetsControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::Mapit

  setup do
    clean_db
    @service = FactoryBot.create(:service)
    mapit_does_not_have_a_postcode("IG6 3HJ")
    Sidekiq::Testing.inline!
  end

  context "POST create" do
    setup do
      @request.env["HTTP_REFERER"] = "http://localhost:3000/admin/services/#{@service.id}"
    end

    should "successfully import a CSV file" do
      as_logged_in_user do
        csv_file = fixture_file_upload(Rails.root.join("test", "fixtures", "good_csv.csv"), "text/csv")
        post :create, params: { service_id: @service.id, data_set: { data_file: csv_file } }
        assert_response :redirect

        # Services are created with 1 data_set initially, so after creating a data_set, there are now 2
        assert_equal 2, Service.first.data_sets.count
        assert_equal 1, Place.count

        place = Place.first
        assert_equal "1 Stop Instruction", place.name
        assert_equal "Power League", place.address1
        assert_equal "Forest Road", place.address2
        assert_equal "Ilford (Fairlop)", place.town
        assert_equal "IG6 3HJ", place.postcode
        assert_equal "Some access notes", place.access_notes
        assert_equal "Some general notes", place.general_notes
        assert_equal "http://www.1stopinstruction.com", place.url
        assert_equal "info@1stopinstruction.com", place.email
        assert_equal "0800 848 8418", place.phone
        assert_equal "0800 848 8419", place.fax
        assert_equal "0800 848 8420", place.text_phone
      end
    end

    should "handle CSV files in a strange character encoding" do
      DataSet.any_instance.stubs(:data_file=).raises(InvalidCharacterEncodingError)

      as_logged_in_user do
        csv_file = fixture_file_upload(Rails.root.join("test", "fixtures", "good_csv.csv"), "text/csv")
        post :create, params: { service_id: @service.id, data_set: { data_file: csv_file } }
        assert_response :redirect
        assert_equal "Could not process CSV file because of the file encoding. Please check the format.", flash[:danger]
        # There is always an initial data set
        assert_equal 1, Service.first.data_sets.count
        assert_equal 0, Place.count
      end
    end

    should "display a new data form if the data set can't be created" do
      as_logged_in_user do
        Tempfile.create("too-much-data") do |tmpfile|
          tmpfile.write("x" * (15.megabytes + 1))
          tmpfile.close
          csv_file = fixture_file_upload(tmpfile.path, "text/csv")
          post :create, params: { service_id: @service.id, data_set: { data_file: csv_file } }

          assert_response(:success)
          assert_template "new_data"
          assert_equal 1, Service.first.data_sets.count
          assert_equal 0, Place.count
        end
      end
    end
  end

  context "POST 'activate'" do
    setup do
      ArchivePlacesWorker.jobs.clear
      Sidekiq::Testing.fake!
    end

    should "allow activating a data_set" do
      as_logged_in_user do
        set = @service.data_sets.create!
        post :activate, params: { service_id: @service.id, id: set.id }
        assert_response :redirect
        assert_equal "Data Set #{set.version} successfully activated", flash[:success]
        @service.reload
        assert_equal set, @service.active_data_set
      end
    end

    should "not allow activating a data_set that hasn't completed processing" do
      as_logged_in_user do
        set = @service.data_sets.create!(data_file: File.open(fixture_file_path("good_csv.csv")))
        post :activate, params: { service_id: @service.id, id: set.id }
        assert_response :redirect
        assert_equal "Couldn't activate data set", flash[:danger]
        @service.reload
        refute_equal set, @service.active_data_set
      end
    end

    context "when activating the latest data set" do
      should "create a background job for archiving the place information" do
        as_logged_in_user do
          post :activate, params: { service_id: @service.id, id: @service.latest_data_set.id }
          job = ArchivePlacesWorker.jobs.last
          service_id_to_process = job["args"].first
          assert_equal @service, Service.find(service_id_to_process)
          assert_equal 1, ArchivePlacesWorker.jobs.count
        end
      end
    end

    context "when duplicating a data set" do
      should "create a background job for duplicating the dataset" do
        as_logged_in_user do
          FactoryBot.create(:place)
          post :duplicate, params: { service_id: @service.id, id: @service.latest_data_set.id }
          job = DuplicateDataSetWorker.jobs.last
          assert_equal @service.id.to_s, job["args"].first
          assert_equal @service.latest_data_set.id.to_s, job["args"].second
          assert_equal 1, DuplicateDataSetWorker.jobs.count
          assert_redirected_to "#{admin_service_path(@service)}#history"
        end
      end
    end
  end
end
