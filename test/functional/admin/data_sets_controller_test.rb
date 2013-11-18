require 'test_helper'

class Admin::DataSetsControllerTest < ActionController::TestCase

  setup do
    clean_db
    @service = FactoryGirl.create(:service)
    GdsApi::Mapit.any_instance.stubs(:location_for_postcode).returns(nil)
    Sidekiq::Testing.inline!
  end

  test "it can successfully import a CSV file" do
    as_logged_in_user do
      @request.env['HTTP_REFERER'] = "http://localhost:3000/admin/services/#{@service.id}"
      csv_file = fixture_file_upload(Rails.root.join('test/fixtures/good_csv.csv'), 'text/csv')
      post :create, :service_id => @service.id, :data_set => {:data_file => csv_file}
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

  test "it handles CSV files with invalid html" do
    as_logged_in_user do
      @request.env['HTTP_REFERER'] = "http://localhost:3000/admin/services/#{@service.id}"
      csv_file = fixture_file_upload(Rails.root.join('test/fixtures/bad_html_csv.csv'), 'text/csv')
      post :create, :service_id => @service.id, :data_set => {:data_file => csv_file}
      assert_response :redirect
      assert_equal "CSV file contains invalid HTML content. Please check the format.", flash[:alert]
      # There is always an initial data set
      assert_equal 1, Service.first.data_sets.count
      assert_equal 0, Place.count
    end
  end

  test "it handles CSV files in a strange character encoding" do
    DataSet.any_instance.stubs(:data_file=).raises(InvalidCharacterEncodingError)

    as_logged_in_user do
      @request.env['HTTP_REFERER'] = "http://localhost:3000/admin/services/#{@service.id}"
      csv_file = fixture_file_upload(Rails.root.join('test/fixtures/good_csv.csv'), 'text/csv')
      post :create, :service_id => @service.id, :data_set => {:data_file => csv_file}
      assert_response :redirect
      assert_equal "Could not process CSV file because of the file encoding. Please check the format.", flash[:alert]
      # There is always an initial data set
      assert_equal 1, Service.first.data_sets.count
      assert_equal 0, Place.count
    end
  end

  context "POST 'activate'" do
    setup do
      Sidekiq::Delay::Worker.jobs.clear
      Sidekiq::Testing.fake!
    end
    
    should "allow activating a data_set" do

      as_logged_in_user do
        set = @service.data_sets.create!
        post :activate, :service_id => @service.id, :id => set.id
        assert_response :redirect
        assert_equal "Data Set #{set.version} successfully activated", flash[:notice]
        @service.reload
        assert_equal set, @service.active_data_set
      end
    end

    should "not allow activating a data_set that hasn't completed processing" do
      as_logged_in_user do
        set = @service.data_sets.create!(:data_file => File.open(fixture_file_path('good_csv.csv')))
        post :activate, :service_id => @service.id, :id => set.id
        assert_response :redirect
        assert_equal "Couldn't activate data set", flash[:notice]
        @service.reload
        refute_equal set, @service.active_data_set
      end
    end

    context "when activating the latest data set" do
      should "create a background job for archiving the place information" do
        as_logged_in_user do
          post :activate, service_id: @service.id, id: @service.latest_data_set.id
          job = Sidekiq::Delay::Worker.jobs.last 
          instance_ary, method_name, args = YAML.load(job['args'].first)
          assert_equal @service, instance_ary.first.send('find', instance_ary.second) 
          assert_equal :archive_places, method_name
          assert_equal 1, Sidekiq::Delay::Worker.jobs.count
        end
      end
    end
  end
end
