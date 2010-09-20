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
  @blog = Wordpress::Blog.new(:blog_uri => "http://localhost", :user => "admin", :password => "wordpress-xmlrpc")
end

When /^make following post:$/ do |table|
  table.hashes.each do |hash|
    hash['creation_date'] = Date.parse(hash.delete('creation_date')) if hash['creation_date']
    hash.merge!({:images => [{:file_path => File.expand_path(hash.delete('image'))}]}) if hash['image']
    post = Wordpress::Post.new(hash)
    @blog.publish(post)
  end
end
