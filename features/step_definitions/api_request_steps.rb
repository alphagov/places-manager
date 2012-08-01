When /^I request the JSON for "(.+?)" without any parameters$/ do |name|
  visit "/places/#{name.parameterize}.json"
end

When /^I request the (\d+) "(.+?)" points nearest to (.+?),(.+?)$/ do |count, name, lat, lng|
  visit "/places/#{name.parameterize}.json?limit=#{count}&lat=#{lat}&lng=#{lng}"
end

When /^I request the JSON for "(.+?)" version (\d+)$/ do |name, version|
  visit "/places/#{name.parameterize}.json?version=#{version}"
end

Then /^I should receive JSON with (\d+) data points$/ do |count|
  data = JSON.parse(page.source)
  assert data
  assert_equal count.to_i, data.length
end
