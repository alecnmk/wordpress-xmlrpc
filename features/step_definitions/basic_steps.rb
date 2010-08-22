When /^I go to wordpress "([^\"]*)" page$/ do |arg1|
  visit("/")
end

When /^I wait for (\d+) seconds+$/ do |seconds|
  sleep(seconds.to_i)
end

Then /^I should see "([^\"]*)"$/ do |expected_content|
  page.should have_content(expected_content)
end

When /^make following post:$/ do |table|
  table.hashes.each do |hash|
    client = Wordpress::Client.new
    client.publish!(Wordpress::Post.new(hash))
  end
end
