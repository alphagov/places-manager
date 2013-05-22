require_relative '../../integration_test_helper'
require_relative '../../business_support_test_helper'

class BusinessSupportSchemeDeleteTest < ActionDispatch::IntegrationTest

  setup do
    ["Super finance triple bonus", "Young business starter award", "Brilliant start-up award", "Wunderbiz"
      ].each_with_index do |title, index|
        FactoryGirl.create(:business_support_scheme, 
                          title: title, 
                          business_support_identifier: index + 1,
                          priority: 1)
    end
  end

  test "deleting a scheme from the index page" do
    visit "/admin/business_support_schemes"
    
    assert page.has_content?("Super finance triple bonus")
    
    within('table tbody tr[2]') do
      click_on "Delete"
    end

    assert page.has_content?("Super finance triple bonus successfully deleted")

    within('table tbody') do
      refute page.has_content?("Super finance triple bonus")
      assert page.has_content?("Brilliant start-up award")
      assert page.has_content?("Wunderbiz")
      assert page.has_content?("Young business starter award")
    end
  end
end
