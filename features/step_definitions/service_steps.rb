Given /^I have previously created the "(.*?)" service$/ do |name|
  params = { name: name, slug: name.parameterize, csv_path: csv_path_for_data(name) }

  @service = create_service(params)
end

Given /^I have previously created a service with the following attributes:$/ do |table|
  params = table.rows_hash.symbolize_keys!
  raise ArgumentError, "name cannot be nil" if params[:name].nil?

  params = { 
    slug: params[:name].parameterize,
    csv_path: csv_path_for_data(params[:name])
  }.merge(params)

  @service = create_service(params)
end

When /^I go to the new service page$/ do
  visit new_admin_service_path
end

When /^I go to the page for the "(.*?)" service$/ do |name|
  visit path_for_service(name)
end

When /^I visit the details tab$/ do
  click_link "Service details"
end

When /^I visit the history tab$/ do
  click_link "Version history"
end

When /^I fill in the form to create the "(.*?)" service with a bad CSV$/ do |name|
  params = {
    name: name,
    slug: name.parameterize,
    csv_path: Rails.root.join("features/support/data/bad.csv")
  }

  fill_in_form_with(params)
end

When /^I fill in the form to create the "(.*?)" service with a PNG claiming to be a CSV$/ do |name|
  params = {
    name: name,
    slug: name.parameterize,
    csv_path: Rails.root.join("features/support/data/rails.csv")
  }

  fill_in_form_with(params)
end

When /^I fill in the form to create the "(.*?)" service with a PNG$/ do |name|
  params = {
    name: name,
    slug: name.parameterize,
    csv_path: Rails.root.join("features/support/data/rails.png")
  }

  fill_in_form_with(params)
end

When /^I fill out the form with the following attributes to create a service:$/ do |table|
  params = table.rows_hash.symbolize_keys!
  raise ArgumentError, "name cannot be nil" if params[:name].nil?

  params = {
    slug: params[:name].parameterize,
    csv_path: csv_path_for_data(params[:name])
  }.merge(params)

  fill_in_form_with(params)
end

Then /^I should be on the page for the "(.*?)" service$/ do |name|
  current_path = URI.parse(current_url).path
  assert_equal path_for_service(name), current_path
end

Then /^there should not be a "(.*?)" service$/ do |name|
  assert_equal 0, Service.where(name: name).count
end

Then /^I should see that the current service has (\d+) missing SNAC codes$/ do |count|
  content = "#{count} places with missing SNAC codes."
  assert page.has_content?(content)
end

Then /^I should not see any text about missing SNAC codes$/ do
  assert !page.has_content?("places with missing SNAC codes.")
end

When /^I activate the most recent data set for the "(.*?)" service$/ do |name|
  steps %Q{
    And I go to the page for the "#{name}" service
    And I visit the history tab
    And I activate the most recent data set
  }
end

When /^I should see (\d+) version panels?$/ do |count|
  version_panels = page.all(:css, "div .data-set")
  assert_equal version_panels.size, count.to_i
end

Then /^the first version panel has the title "(.*?)"$/ do |title|
  within "div.data-set:nth-child(1)" do
    within "h3.panel-title" do
      assert page.has_content?(title)
    end
  end
end

Then /^the first version panel has the text "(.*?)"$/ do |text|
  within "div.data-set:nth-child(1)" do
    assert page.has_content?(text)
  end
end

Then /^the first version panel shows a warning about missing SNAC codes$/ do
  within "div.data-set:nth-child(1)" do
    assert page.has_css?("p.missing-snac-warning")
  end
end
