Given /^I have previously created the "(.*?)" service$/ do |name|
  create_service(name)
end

When /^I go to the new service page$/ do
  visit new_admin_service_path
end

Then /^show me the page$/ do
  save_and_open_page
end

Then /^I fill in the form to create the "(.*?)" service$/ do |name|
  fill_in 'Name', with: name
  fill_in 'Slug', with: name.parameterize
  fill_in 'Source of data', with: 'Testing'
  attach_file 'Data file', csv_path_for_data(name)
  click_button 'Create Service'
end

When /^I go to the page for the "(.*?)" service$/ do |name|
  visit path_for_service(name)
end

Then /^I should be on the page for the "(.*?)" service$/ do |name|
  current_path = URI.parse(current_url).path
  assert_equal path_for_service(name), current_path
end

Then /^I should see an indication that my data set contained (\d+) items$/ do |count|
  assert page.has_content?("containing #{count} places")
end

When /^I upload a new data set$/ do
  within "#new-data" do
    attach_file "Data file", csv_path_for_data("Register Offices")
    click_button "Create Data set"
  end
end

Then /^I should see that there are now two data sets$/ do
  assert page.has_content?("Version 2 uploaded at")
end