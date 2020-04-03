Given /^I am (?:a|an) (admin)$/ do |_role|
  user = FactoryBot.create(:user, name: "user")
  login_as user
end
