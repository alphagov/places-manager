Given /^I have previously created the "(.*?)" service$/ do |name|
  @service = create_service(name)
end

Given /^I have uploaded a (second|third) data set$/ do |ordinal|
  upload_extra_data_set(@service)
end

Given /^background processing has completed$/ do
  run_all_delayed_jobs
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

When /^I upload a new data set with a CSV in the wrong format$/ do
  within "#new-data" do
    attach_file "Data file", Rails.root.join('features/support/data/wrong_format.csv')
    click_button "Create Data set"
  end
end

When /^I upload a new data set with a PNG claiming to be a CSV$/ do
  within "#new-data" do
    attach_file "Data file", Rails.root.join('features/support/data/rails.csv')
    click_button "Create Data set"
  end
end

When /^I visit the history tab$/ do
  click_link 'Version history'
end

When /^I click "Activate"$/ do
  click_button 'Activate'
end

When /^I click "Duplicate"$/ do
  click_button 'Duplicate'
end

When /^I fill in the form to create the "(.*?)" service with a bad CSV$/ do |name|
  fill_in_form_with(name, Rails.root.join('features/support/data/bad.csv'))
end

When /^I fill in the form to create the "(.*?)" service with a PNG claiming to be a CSV$/ do |name|
  fill_in_form_with(name, Rails.root.join('features/support/data/rails.csv'))
end

When /^I fill in the form to create the "(.*?)" service with a PNG$/ do |name|
  fill_in_form_with(name, Rails.root.join('features/support/data/rails.png'))
end

When /^I go to the page for the latest data set for the "(.*?)" service$/ do |name|
  visit path_for_latest_data_set_for_service(name)
end

When /^I go to the page for the active data set for the "(.*?)" service$/ do |name|
  visit path_for_active_data_set_for_service(name)
end

When /^I go to the page for the second data set for the "(.*?)" service$/ do |name|
  visit path_for_data_set_version_for_service(name, 2)
end

When /^I click "Edit" on a record$/ do
  within "table.table-places" do
    click_link "edit"
  end
end

When /^I update the name to be "(.*?)"$/ do |name|
  fill_in_place_form_with(name)
end

Then /^I should see an indication that my file wasn't accepted$/ do
  assert page.has_content?("Could not process data file. Please check the format.")
end

Then /^I should see an indication that my data set import failed$/ do
  assert page.has_content?("This may well mean the imported data was in the wrong format")
end

Then /^show me the page$/ do
  save_and_open_page
end

Then /^I fill in the form to create the "(.*?)" service$/ do |name|
  fill_in_form_with(name, csv_path_for_data(name))
end

Then /^I should be on the page for the "(.*?)" service$/ do |name|
  current_path = URI.parse(current_url).path
  assert_equal path_for_service(name), current_path
end

Then /^I should be on the page for the latest data set for the "(.*?)" service$/ do |name|
  current_path = URI.parse(current_url).path
  assert_equal path_for_latest_data_set_for_service(name), current_path
end

Then /^I should see an indication that my data set is awaiting processing$/ do
  assert page.has_content?("Places data is currently being processed")
end

Then /^I should see an indication that my data set contained (\d+) items$/ do |count|
  assert page.has_content?("#{count} places")
end

Then /^I should see an indication that my data set is empty$/ do
  assert page.has_content?("There are no places associated with this data set. This may well mean the imported data was in the wrong format")
end

Then /^I should see that there are now two data sets$/ do
  assert page.has_content?("Version 2")
end

Then /^I should see that there are now three data sets$/ do
  assert page.has_content?("Version 3")
end

Then /^I should see that the second data set is active$/ do
  assert page.has_content?("Version 2 active")
end

Then /^there should still just be one data set$/ do
  assert_equal 1, Service.first.data_sets.count
end

Then /^there shouldn't be a "(.*?)" service$/ do |name|
  assert_equal 0, Service.where(name: name).count
end

Then /^there should be a place named "(.*?)"$/ do |name|
  within "table.table-places" do
    assert page.has_content?(name)
  end
end

Then /^I should not see an "edit" action for a record$/ do
  within "table.table-places" do
    assert ! page.has_link?("edit")
  end
end

Then /^I should see an indication that the first data set is being archived$/ do
  assert page.has_content?("Version 1 Archiving")
end

Then /^I should not see the first data set$/ do
  assert ! page.has_content?("Version 1")
end
