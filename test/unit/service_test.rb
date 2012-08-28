require 'test_helper'

class ServiceTest < ActiveSupport::TestCase

  def setup_service
    Service.create(
      name: 'Important Government Service',
      slug: 'important-government-service'
    )
  end

  test "creating a service creates an initial data set" do
    s = setup_service
    assert_equal 1, s.data_sets.count
    assert_equal 1, s.data_sets[0].version
  end

  test "creating a second data set increments the version" do
    s = setup_service
    s.data_sets.create!
    assert_equal [1, 2], s.data_sets.map(&:version)
  end

  test "data set numbering works with skipped versions" do
    s = setup_service
    s.data_sets[0].update_attributes!(version: 2)
    s.data_sets.create!
    assert_equal [2, 3], s.data_sets.map(&:version)
  end

  test "data set numbering works out of order" do
    s = setup_service
    s.data_sets[0].update_attributes!(version: 5)
    s.data_sets.create!(version: 3)
    s.data_sets.create!
    assert_equal [5, 3, 6], s.data_sets.map(&:version)
  end

  test "data set defaults to 1 if there are no data sets" do
    s = setup_service
    s.data_sets.clear
    s.data_sets.create!
    assert_equal [1], s.data_sets.map(&:version)
  end
end
