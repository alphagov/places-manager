Then(/^I should see the "(.*?)" field filled with "(.*?)"$/) do |field, text|
  expect(page).to have_field(field, with: text)
end

Then(/^I should see the "(.*?)" select field set to "(.*?)"$/) do |field, text|
  expect(page).to have_select(field, selected: text)
end
