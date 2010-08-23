Given /^all posts and comments cleaned out$/ do
  mysql = Mysql.new("localhost", "root", "", "wordpress_xmlrpc")
  mysql.query("delete from wp_posts")
  mysql.query("delete from wp_postmeta")
  mysql.query("delete from wp_comments")
  mysql.query("delete from wp_commentmeta")
end
