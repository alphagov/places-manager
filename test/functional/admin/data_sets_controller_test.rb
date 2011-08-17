require 'test_helper'

class Admin::DataSetsControllerTest < ActionController::TestCase

  def setup_service
    Service.first || Service.create(:name => 'Important Government Service', :slug => 'important-government-service')
  end
    
  test "it handles invalid CSV files gracefully" do
    as_logged_in_user do
      @request.env['HTTP_REFERER'] = "http://localhost:3000/admin/services/#{setup_service.id}"
      csv_file = fixture_file_upload(Rails.root.join('test/fixtures/bad_csv.csv'), 'text/csv')
      post :create, :service_id => setup_service.id, :data_set => {:data_file => csv_file}
      assert_response :redirect
      assert_equal "Could not process CSV file. Please check the format.", flash[:alert]
    end
  end
end
