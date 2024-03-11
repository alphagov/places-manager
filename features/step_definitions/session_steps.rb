Given(/^I am (?:a|an) (editor)$/) do |_role|
  user = FactoryBot.create(:user, name: "user", organisation_slug: "test-department", permissions: %w[Editor])
  login_as user
end

Given(/^I am (?:a|an) (GDS editor)$/) do |_role|
  user = FactoryBot.create(:user, name: "user", organisation_slug: "government-digital-service", permissions: ["GDS Editor"])
  login_as user
end

Given(/^test-department exists$/) do
  GdsApiHelper.new.stub_organisations_test_department
end
