require 'test_helper'

class SafeHtmlTest < ActiveSupport::TestCase
  test "all models should use this validator" do
    classes = ObjectSpace.each_object(::Module).select do |klass|
      klass < Mongoid::Document
    end

    classes.each do |klass|
      assert_includes klass.validators.map(&:class), SafeHtml, "#{klass} must be validated with SafeHtml"
    end
  end
end