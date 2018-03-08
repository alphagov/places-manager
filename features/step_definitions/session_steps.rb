Given /^I am (?:a|an) (admin)$/ do |role|
  user = FactoryBot.create(:user, name: "user")
  login_as user
end
