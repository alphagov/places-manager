require_relative "../../integration_test_helper.rb"
require_relative '../../business_support_test_helper'

class BusinessSupportSchemeExportTest < ActionDispatch::IntegrationTest

  setup do
    make_facets(:business_support_business_type, ["Global megacorp", "Private limited company", "Charity"])
    make_facets(:business_support_location, ["England", "Scotland", "Wales", "Northern Ireland", "London", "Yorkshire and the Humber"])
    make_facets(:business_support_purpose, ["Making the most of the Internet", "Exporting or finding overseas partners", 
                "Finding new customers and markets", "Energy efficiency and the environment"])
    make_facets(:business_support_sector, ["Agriculture", "Healthcare", "Manufacturing"])
    make_facets(:business_support_stage, ["Pre-startup", "Startup", "Grow and sustain"])
    make_facets(:business_support_type, ["Award", "Loan", "Grant"])

    FactoryGirl.create(:business_support_scheme, :title => "Super finance triple bonus", :business_support_identifier => 1,
                      :business_types => ['private-limited-company', 'charity'], :locations => ['england'],
                      :sectors => ['healthcare'], :stages => ['startup', 'grow-and-sustain'])
    FactoryGirl.create(:business_support_scheme, :title => "Young business starter award", :business_support_identifier => 2)
    FactoryGirl.create(:business_support_scheme, :title => "Brilliant start-up award", :business_support_identifier => 3)
  end

  test " CSV export of schemes" do
    get "/admin/business_support_schemes.csv"

    assert last_response.ok?
    assert_equal 'text/csv', last_response.headers['Content-Type']
    assert_equal 'attachment; filename="business_support_schemes.csv"', last_response.headers['Content-Disposition']

    data = CSV.parse(last_response.body, :headers => true)
    assert_equal ["Brilliant start-up award", "Super finance triple bonus", "Young business starter award"], data.map {|r| r["title"] }

    assert_equal "private-limited-company,charity", data[1]["business types"]
    assert_equal "england", data[1]["locations"]
    assert_equal "", data[1]["purposes"]
    assert_equal "healthcare", data[1]["sectors"]
    assert_equal "startup,grow-and-sustain", data[1]["stages"]
    assert_equal "", data[1]["support types"]
  end
end
