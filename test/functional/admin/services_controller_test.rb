require 'test_helper'

class Admin::ServicesControllerTest < ActionController::TestCase
  test "it handles invalid CSV files gracefully" do
    as_logged_in_user do
      csv_file = fixture_file_upload(Rails.root.join('test/fixtures/bad_csv.csv'), 'text/csv')
      post :create, :service => {:name => 'Bad Data', :slug => 'bad-data', :data_file => csv_file}
      assert_response :success
      assert_equal "Could not process CSV file. Please check the format.", flash[:alert]
    end
  end
end