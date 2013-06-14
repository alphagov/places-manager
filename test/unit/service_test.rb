require 'test_helper'

class ServiceTest < ActiveSupport::TestCase

  context "validations" do
    setup do
      @service = FactoryGirl.build(:service)
    end

    should "have a valid factory" do
      assert @service.valid?
    end

    should "require a name" do
      @service.name = ''
      refute @service.valid?
      assert_equal 1, @service.errors[:name].count
    end

    context "on slug" do
      should "be required" do
        @service.slug = ''
        refute @service.valid?
        assert_equal 1, @service.errors[:slug].count
      end

      should "be unique" do
        service2 = FactoryGirl.create(:service, :slug => 'a-service')
        @service.slug = 'a-service'
        refute @service.valid?
        assert_equal 1, @service.errors[:slug].count
      end

      should "have database level uniqueness constraint" do
        service2 = FactoryGirl.create(:service, :slug => 'a-service')
        @service.slug = 'a-service'
        assert_raises Mongo::OperationFailure do
          @service.safely.save :validate => false
        end
      end

      should "look like a slug" do
        [
          'a space',
          'full.stop',
          'this&that',
        ].each do |slug|
          @service.slug = slug
          refute @service.valid?
          assert_equal 1, @service.errors[:slug].count
        end

        [
          'dashed-with-numbers-123',
          'under_score',
        ].each do |slug|
          @service.slug = slug
          assert @service.valid?
        end
      end
    end

  end

  context "populating data_set version" do
    def setup_service
      Service.create(
        name: 'Important Government Service',
        slug: 'important-government-service'
      )
    end

    should "creating a service creates an initial data set" do
      s = setup_service
      assert_equal 1, s.data_sets.count
      assert_equal 1, s.data_sets[0].version
    end

    should "creating a second data set increments the version" do
      s = setup_service
      s.data_sets.create!
      assert_equal [1, 2], s.data_sets.map(&:version)
    end

    should "data set numbering works with skipped versions" do
      s = setup_service
      s.data_sets[0].update_attributes!(version: 2)
      s.data_sets.create!
      assert_equal [2, 3], s.data_sets.map(&:version)
    end

    should "data set numbering works out of order" do
      s = setup_service
      s.data_sets[0].update_attributes!(version: 5)
      s.data_sets.create!(version: 3)
      s.data_sets.create!
      assert_equal [5, 3, 6], s.data_sets.map(&:version)
    end

    should "data set defaults to 1 if there are no data sets" do
      s = setup_service
      s.data_sets.clear
      s.data_sets.create!
      assert_equal [1], s.data_sets.map(&:version)
    end
  end
end
