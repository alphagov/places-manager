require 'test_helper'

class ServiceTest < ActiveSupport::TestCase
  test "creating a service creates an initial data set" do
    s = Service.create(:name => 'Important Government Service', :slug => 'important-government-service')
    assert_equal 1, s.data_sets.count
  end
end
