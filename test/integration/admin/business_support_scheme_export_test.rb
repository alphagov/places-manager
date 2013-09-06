require_relative "../../integration_test_helper.rb"
require_relative '../../business_support_test_helper'

class BusinessSupportSchemeExportTest < ActionDispatch::IntegrationTest

  setup do
    make_facets(:business_support_business_type, ["Global megacorp", "Private limited company", "Charity"])
    make_facets(:business_support_business_size, ["Under 10", "Up to 249", "Between 250 and 500", "Between 501 and 1000", "Over 1000"])
    make_facets(:business_support_location, ["England", "Scotland", "Wales", "Northern Ireland", "London", "Yorkshire and the Humber"])
    make_facets(:business_support_purpose, ["Making the most of the Internet", "Exporting or finding overseas partners",
                "Finding new customers and markets", "Energy efficiency and the environment"])
    make_facets(:business_support_sector, ["Agriculture", "Healthcare", "Manufacturing"])
    make_facets(:business_support_stage, ["Pre-startup", "Startup", "Grow and sustain"])
    make_facets(:business_support_type, ["Award", "Loan", "Grant"])

    FactoryGirl.create(:business_support_scheme, :title => "Super finance triple bonus",
                       :business_support_identifier => 1,
                       :business_types => ['private-limited-company', 'charity'],
                       :business_sizes => ['under-10', 'up-to-249'],
                       :locations => ['england'],
                       :sectors => ['healthcare'], :stages => ['startup', 'grow-and-sustain'],
                       :start_date => Date.parse("2013-02-03"),
                       :end_date => Date.parse("2013-03-01"))
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


    expected_data = {
      "business types" => "private-limited-company,charity",
      "business sizes" => "under-10,up-to-249",
      "end date" => "01/03/2013",
      "locations" => "england",
      "purposes" => "",
      "sectors" => "healthcare",
      "stages" => "startup,grow-and-sustain",
      "start date" => "03/02/2013",
      "support types" => ""
    }

    assert_equal expected_data, data[1].to_hash.slice(*expected_data.keys)
    assert_equal "", data[2]["start date"]
  end
end
