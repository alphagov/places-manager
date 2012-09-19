if ENV["COVERAGE"]
  require 'simplecov'
  require 'simplecov-rcov'

  SimpleCov.start 'rails'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
end

require 'database_cleaner'

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  include MiniTest::Assertions

  def clean_db
    DatabaseCleaner.clean
  end
  set_callback :teardown, :before, :clean_db


  def as_logged_in_user(&block)
    @controller.stubs(:authenticate_user!).returns(true)
    @controller.stubs(:require_signin_permission!).returns(true)
    @controller.stubs(:user_signed_in?).returns(true)
    yield
    @controller.unstub(:user_signed_in?)
    @controller.unstub(:authenticate_user!)
  end
  
  def assert_association(clazz, association, associate, options={})
    reflected_assoc = clazz.reflect_on_association(associate)
    flunk "#{clazz} has no association with #{associate}" if reflected_assoc.nil?
    assert_equal association, reflected_assoc.macro
    options.each do |key, value|
      assert_equal value, reflected_assoc.options[key]
    end
  end
  
  def assert_validates_uniqueness_of(clazz, *attributes) 
    has_validator = false
    attributes.each do |attribute|
      validators = clazz._validators[attribute]
      if validators.empty? 
        flunk "No validations for #{attribute}"    
      else
        validators.each do |validator|
          if validator.class == ::Mongoid::Validations::UniquenessValidator
            has_validator = (attributes.sort! == validator.attributes.sort!)
            break
          end
        end
      end
    end
    assert has_validator, "#{clazz} does not validate_uniqueness_of #{attributes}"
  end
end
