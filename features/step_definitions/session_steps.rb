Given(/^I am (?:a|an) (editor)$/) do |_role|
  user = FactoryBot.create(:user, name: "user", organisation_slug: "test-department", permissions: %w[Editor])
  login_as user
end

Given(/^I am (?:a|an) (GDS editor)$/) do |_role|
  user = FactoryBot.create(:user, name: "user", organisation_slug: "government-digital-service", permissions: ["GDS Editor"])
  login_as user
end

Given(/^test-department exists$/) do
  stub_organisations_test_department
end

Given("there are no frontend pages") do
  stub_search_finds_no_govuk_pages
end
