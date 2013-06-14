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

  should "create an initial data_set when creating a service" do
    Service.create(
      name: 'Important Government Service',
      slug: 'important-government-service'
    )

    s = Service.first
    assert_equal 1, s.data_sets.count
  end
end
