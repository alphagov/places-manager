require_relative 'test_helper'

module BusinessSupportTestHelper

  def make_facets(facet_type, names)
    names.each do |name|
      slug = name.parameterize
      instance_variable_set(:"@#{slug.underscore}", FactoryGirl.create(facet_type, name: name, slug: slug))
    end
  end

end

class ActionController::TestCase
  include BusinessSupportTestHelper
end

class ActionDispatch::IntegrationTest
  include BusinessSupportTestHelper
  setup do
    @controller = Admin::BusinessSupportSchemesController
    GDS::SSO.test_user = FactoryGirl.create(:user)
  end
end
