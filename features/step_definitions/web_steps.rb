Then(/^I should see the "(.*?)" field filled with "(.*?)"$/) do |field, text|
  assert page.has_field?(field, with: text)
end

Then(/^I should see the "(.*?)" select field set to "(.*?)"$/) do |field, text|
  assert page.has_select?(field, selected: text)
end
