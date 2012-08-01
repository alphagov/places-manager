Given /^I have previously created the "(.*?)" service$/ do |name|
  @service = create_service(name)
end

Given /^I have uploaded a second data set$/ do
  upload_extra_data_set(@service)
end

Given /^the data has been geocoded$/ do
  Service.all.each do |service|
    service.data_sets.each do |set|
      if ENV['RESET_ERRORS']
        set.places.with_geocoding_errors.map { |p| p.geocode_error = nil }
        set.save
      end
      set.places.needs_geocoding.each do |place|
        place.geocode!
        $stderr.puts place.geocode_error if place.geocode_error
      end
    end
  end
end

When /^I go to the new service page$/ do
  visit new_admin_service_path
end

When /^I go to the page for the "(.*?)" service$/ do |name|
  visit path_for_service(name)
end

When /^I upload a new data set$/ do
  within "#new-data" do
    attach_file "Data file", csv_path_for_data("Register Offices")
    click_button "Create Data set"
  end
end

When /^I click "Activate"$/ do
  click_button 'Activate'
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

Then /^I should be on the page for the "(.*?)" service$/ do |name|
  current_path = URI.parse(current_url).path
  assert_equal path_for_service(name), current_path
end

Then /^I should see an indication that my data set contained (\d+) items$/ do |count|
  assert page.has_content?("containing #{count} places")
end

Then /^I should see that there are now two data sets$/ do
  assert page.has_content?("Version 2 uploaded at")
end

Then /^I should see that the second data set is active$/ do
  assert page.has_content?("Currently serving version 2")
end