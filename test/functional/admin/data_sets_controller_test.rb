require 'test_helper'

class Admin::DataSetsControllerTest < ActionController::TestCase

  setup do
    clean_db
  end

  def setup_service
    Service.create(:name => 'Important Government Service', :slug => 'important-government-service')
  end

  test "it can successfully import a CSV file" do
    as_logged_in_user do
      @request.env['HTTP_REFERER'] = "http://localhost:3000/admin/services/#{setup_service.id}"
      csv_file = fixture_file_upload(Rails.root.join('test/fixtures/good_csv.csv'), 'text/csv')
      post :create, :service_id => setup_service.id, :data_set => {:data_file => csv_file}
      assert_response :redirect

      assert_equal 1, Service.first.data_sets.count
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
      # Assert that no geocoding has taken place yet to ensure that
      # Place#handle_postcode_change is not called when loading a new DataSet.
      assert_nil place.location
      assert_nil place.geocode_error
    end
  end

  test "it handles invalid CSV files gracefully" do
    as_logged_in_user do
      @request.env['HTTP_REFERER'] = "http://localhost:3000/admin/services/#{setup_service.id}"
      csv_file = fixture_file_upload(Rails.root.join('test/fixtures/bad_csv.csv'), 'text/csv')
      post :create, :service_id => setup_service.id, :data_set => {:data_file => csv_file}
      assert_response :redirect
      assert_equal "Could not process CSV file. Please check the format.", flash[:alert]
      # There is always an initial data set
      assert_equal 1, Service.first.data_sets.count
      assert_equal 0, Place.count
    end
  end

  test "it handles CSV files with invalid html" do
    as_logged_in_user do
      @request.env['HTTP_REFERER'] = "http://localhost:3000/admin/services/#{setup_service.id}"
      csv_file = fixture_file_upload(Rails.root.join('test/fixtures/bad_html_csv.csv'), 'text/csv')
      post :create, :service_id => setup_service.id, :data_set => {:data_file => csv_file}
      assert_response :redirect
      assert_equal "CSV file contains invalid HTML content. Please check the format.", flash[:alert]
      # There is always an initial data set
      assert_equal 1, Service.first.data_sets.count
      assert_equal 0, Place.count
    end
  end

  test "it's possible to activate a data set" do
    as_logged_in_user do
      service = setup_service
      set = service.data_sets.create!
      post :activate, :service_id => service.id, :id => set.id
      assert_response :redirect
      assert_equal "Data Set #{set.version} successfully activated", flash[:notice]
      service.reload
      assert_equal set, service.active_data_set
    end
  end
end
