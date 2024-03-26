Given(/^I have uploaded a (second|third) data set$/) do |_ordinal|
  upload_extra_data_set(@service)
end

Given(/^background processing has completed$/) do
  run_all_delayed_jobs
end

When(/^I upload a new data set$/) do
  attach_file "Upload a file", csv_path_for_data("Register Offices")
  click_button "Upload"
end

When(/^I upload a new data set with a CSV in the wrong format$/) do
  attach_file "Upload a file", Rails.root.join("features/support/data/wrong_format.csv")
  click_button "Upload"
end

When(/^I upload a new data set with a PNG claiming to be a CSV$/) do
  attach_file "Upload a file", Rails.root.join("features/support/data/rails.csv")
  click_button "Upload"
end

When(/^I upload a new data set with a CSV with missing GSS codes$/) do
  attach_file "Upload a file", Rails.root.join("features/support/data/register-offices-with-missing-gss-codes.csv")
  click_button "Upload"
end

When(/^I make it active$/) do
  click_button "Make Active"
end

When(/^I view the most recent data set$/) do
  within "tbody tr:last" do
    click_link "View"
  end
end

When(/^I go to the page for the latest data set for the "(.*?)" service$/) do |name|
  visit path_for_latest_data_set_for_service(name)
end

When(/^I go to the page for the active data set for the "(.*?)" service$/) do |name|
  visit path_for_active_data_set_for_service(name)
end

When(/^I go to the page for the second data set for the "(.*?)" service$/) do |name|
  visit path_for_data_set_version_for_service(name, 2)
end

When(/^I click "Edit" on a record$/) do
  within "table.table-places tbody tr:first" do
    click_link "Edit place"
  end
end

When(/^I (activate|duplicate) the most recent data set$/) do |button_choice|
  within "#history .row:first .data-set:first" do
    click_on button_choice.titleize
  end
end

When(/^I update the name to be "(.*?)"$/) do |name|
  fill_in_place_form_with(name)
end

When(/^I export the latest "(.*?)" data set to CSV$/) do |name|
  visit path_for_latest_data_set_for_service(name)
  click_link "CSV"
  @exported_csv_data = page.source
end

When(/^I upload the exported CSV to the "(.*?)" service$/) do |name|
  visit path_for_service(name)
  click_link "Upload new dataset"
  upload_csv_data(@exported_csv_data)
  run_all_delayed_jobs
end

Then(/^I should see an indication that my file was not accepted$/) do
  expect(page).to have_content("Could not process CSV file. Please check the format.")
end

Then(/^I should see an indication that my data set import failed$/) do
  expect(page).to have_content("This may well mean the imported data was in the wrong format")
end

Then(/^I should see an indication that my data set is awaiting processing$/) do
  expect(page).to have_content("Places data is currently being processed")
end

Then(/^I should see an indication that my data set contained (\d+) items$/) do |count|
  expect(page).to have_content("Places #{count}")
end

Then(/^I should see an indication that my data set is empty$/) do
  expect(page).to have_content("Places 0")
end

Then(/^I should see an indication that there was an import problem$/) do
  expect(page).to have_content("Database error occurred. Please try re-importing.")
end

Then(/^I should be on the page for the latest data set for the "(.*?)" service$/) do |name|
  expect(path_for_latest_data_set_for_service(name)).to eq(current_path)
end

Then(/^I should see that there are now (\d+) data sets$/) do |count|
  expect(page).to have_content("Version #{count}")
end

Then(/^I should see that the second data set is active$/) do
  expect(page).to have_content("Version 2")
  expect(page).to have_content("Use Active")
end

Then("I should see that the current data set is version {int}") do |int|
  expect(page).to have_content("Version #{int}")
end

Then("I should see {int} versions in the list") do |int|
  expect(page.all("tbody tr").count).to eq(int)
end

Then(/^I should see "(.*)" versions in the listthat the second data set is active$/) do
  expect(page).to have_content("Version 2 active")
end

Then(/^there should still just be one data set$/) do
  expect(Service.first.data_sets.count).to eq(1) # assert_equal 1, Service.first.data_sets.count
end

Then(/^the "(.*?)" service should have two data sets$/) do |name|
  expect(Service.where(name:).first.data_sets.count).to eq(2) # assert_equal 2, Service.where(name: name).first.data_sets.count
end

Then(/^there should be a place named "(.*?)"$/) do |name|
  within "table.table-places" do
    expect(page).to have_content(name)
  end
end

Then(/^the places should be identical between the datasets in the "(.*?)" service$/) do |name|
  service = Service.where(name:).first
  data_set1 = service.data_sets.first
  data_set2 = service.data_sets.last
  [data_set1, data_set2].each { |data_set| expect(data_set.places.count).to eq(1) }

  place1 = data_set1.places.first
  place2 = data_set2.places.first

  expected_identical_attributes = Place.attribute_names - %w[id data_set_version created_at updated_at]
  expected_identical_attributes.each do |attribute|
    expect(place1.send(attribute.to_sym)).to eq(place2.send(attribute.to_sym))
  end
end

Then(/^I should not see an "edit" action for a record$/) do
  within "table.table-places" do
    expect(page).not_to have_link("edit")
  end
end

Then("I should see an indication that the first data set is being archived") do
  expect(page).to have_content("Archiving 1")
end

Then("I should not see the first data set") do
  expect(page).not_to have_content("active 1")
end
