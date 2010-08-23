When /^I go to wordpress "([^\"]*)" page$/ do |page|
  case page
  when "home"
    visit("/")
  else
    raise "Undefined page #{page}"
  end
end

When /^I wait for (\d+) seconds+$/ do |seconds|
  sleep(seconds.to_i)
end

Then /^I should see "([^\"]*)"$/ do |expected_content|
  page.should have_content(expected_content)
end

Given /^I have a blog control$/ do
  @blog = Wordpress::Blog.new(:host => "http://localhost", :user => "admin", :password => "wordpress-xmlrpc")
end

When /^make following post:$/ do |table|
  table.hashes.each do |hash|
    hash['publish_date'] = Date.parse(hash.delete('publish_date')) if hash['publish_date']
    post = Wordpress::Post.new(hash)
    @blog.publish(post)
  end
end
