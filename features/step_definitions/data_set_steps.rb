Given /^I have uploaded a (second|third) data set$/ do |ordinal|
  upload_extra_data_set(@service)
end

Given /^background processing has completed$/ do
  run_all_delayed_jobs
end

When /^I upload a new data set$/ do
  within "#new-data" do
    attach_file "Data file", csv_path_for_data("Register Offices")
    click_button "Create Data set"
  end
end

When /^I upload a new data set with a CSV in the wrong format$/ do
  within "#new-data" do
    attach_file "Data file", Rails.root.join("features/support/data/wrong_format.csv")
    click_button "Create Data set"
  end
end

When /^I upload a new data set with a PNG claiming to be a CSV$/ do
  within "#new-data" do
    attach_file "Data file", Rails.root.join("features/support/data/rails.csv")
    click_button "Create Data set"
  end
end

When /^I upload a new data set with a CSV with missing SNAC codes$/ do
  within "#new-data" do
    attach_file "Data file", Rails.root.join("features/support/data/register-offices-with-missing-snac-codes.csv")
    click_button "Create Data set"
  end
end

When /^I click "Activate"$/ do
  click_button "Activate"
end

When /^I click "Duplicate"$/ do
  click_button "Duplicate"
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
  within "table.table-places tbody tr:first" do
    click_link "Edit place"
  end
end

When /^I (activate|duplicate) the most recent data set$/ do |button_choice|
  within "#history .row:first .data-set:first" do
    click_on button_choice.titleize
  end
end

When /^I update the name to be "(.*?)"$/ do |name|
  fill_in_place_form_with(name)
end

When /^I export the latest "(.*?)" data set to CSV$/ do |name|
  visit path_for_latest_data_set_for_service(name)
  click_link "CSV"
  @exported_csv_data = page.source
end

When /^I upload the exported CSV to the "(.*?)" service$/ do |name|
  visit path_for_service(name)
  upload_csv_data(@exported_csv_data)
  run_all_delayed_jobs
end

Then /^I should see an indication that my file was not accepted$/ do
  assert page.has_content?("Could not process CSV file. Please check the format.")
end

Then /^I should see an indication that my data set import failed$/ do
  assert page.has_content?("This may well mean the imported data was in the wrong format")
end

Then /^show me the page$/ do
  save_and_open_page
end

Then /^I should see an indication that my data set is awaiting processing$/ do
  assert page.has_content?("Places data is currently being processed")
end

Then /^I should see an indication that my data set contained (\d+) items$/ do |count|
  assert page.has_content?("#{count} places")
end

Then /^I should see an indication that my data set is empty$/ do
  assert page.has_content?("No places are associated with this set. The imported data could be in the wrong format.")
end

Then /^I should be on the page for the latest data set for the "(.*?)" service$/ do |name|
  assert_equal path_for_latest_data_set_for_service(name), current_path
end

Then /^I should see that there are now (\d+) data sets$/ do |count|
  assert page.has_content?("Version #{count}")
end

Then /^I should see that the second data set is active$/ do
  assert page.has_content?("Version 2 active")
end

Then /^there should still just be one data set$/ do
  assert_equal 1, Service.first.data_sets.count
end

Then /^the "(.*?)" service should have two data sets$/ do |name|
  assert_equal 2, Service.where(name: name).first.data_sets.count
end

Then /^there should be a place named "(.*?)"$/ do |name|
  within "table.table-places" do
    assert page.has_content?(name)
  end
end

Then /^the places should be identical between the datasets in the "(.*?)" service$/ do |name|
  service = Service.where(name: name).first
  data_set_1 = service.data_sets.first
  data_set_2 = service.data_sets.last
  [data_set_1, data_set_2].each { |data_set| assert_equal 1, data_set.places.count }

  place_1 = data_set_1.places.first
  place_2 = data_set_2.places.first

  expected_identical_attributes = Place.attribute_names - ["_id", "data_set_version"]
  expected_identical_attributes.each do |attribute|
    assert_equal place_1.send(attribute.to_sym), place_2.send(attribute.to_sym)
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

Then("I should see that a duplicating job was enqueued for data set version {int}") do |int|
  assert page.has_content?("Your request for a duplicate of data set version #{int} is being processed. This can take a few minutes.")
end
