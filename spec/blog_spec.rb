require 'spec_helper'

describe Wordpress::Blog do
  describe "initialize" do
    before(:each) do
      @valid_params = {
        :blog_uri => "http://localhost",
        :user => "admin",
        :password => "password"
      }
    end

    it "should require error without host param provided" do
      @valid_params.delete :blog_uri
      lambda{
        Wordpress::Blog.new(@valid_params)
      }.should raise_error ArgumentError, ":blog_uri param is required"
    end

    it "should raise error without user param provided" do
      @valid_params.delete :user
      lambda{
        Wordpress::Blog.new(@valid_params)
      }.should raise_error ArgumentError, ":user param is required"
    end

    it "should raise error without password param provided" do
      @valid_params.delete :password
      lambda{
        Wordpress::Blog.new(@valid_params)
      }.should raise_error ArgumentError, ":password param is required"
    end

    it "should require valid blog URI" do
      lambda{
        Wordpress::Blog.new(:blog_uri => "invalid uri")
      }.should raise_error URI::InvalidURIError
    end

    it "should create new blog instance with valid host param provided" do
      blog = Wordpress::Blog.new(@valid_params)
      blog.should_not be_nil
    end
  end

  describe "publish" do
    it "should make appropriate call to xmlrpc api" do
      client_mock = mock("client")
      XMLRPC::Client.should_receive(:new2).with("http://localhost/xmlrpc").and_return(client_mock)

      blog = Wordpress::Blog.new(
                                 :blog_uri => "http://localhost",
                                 :user => "admin",
                                 :password => "wordpress-xmlrpc",
                                 :blog_id => 99
                                 )
      post = Wordpress::Post.new(
                                 :title => "Hey ho",
                                 :content => "Content",
                                 :excerpt => "Excerpt",
                                 :publish_date => Date.parse("01.08.2010"))

      client_mock.should_receive(:call).with("metaWeblog.newPost", 99, "admin", "wordpress-xmlrpc", post.to_struct, true).and_return("123")

      blog.publish(post).should be_true
      post.id.should == 123
      post.published.should be_true
    end
  end

  describe "recent_posts" do
    it "should make appropriate call to xmlrpc api and return list of posts" do
      client_mock = mock("client")
      XMLRPC::Client.should_receive(:new2).with("http://localhost/xmlrpc").and_return(client_mock)

      blog = Wordpress::Blog.new(
                      :blog_uri => "http://localhost",
                      :user => "admin",
                      :password => "wordpress-xmlrpc",
                      :blog_id => 0
                      )

      post_structs = (1..10).collect do |index|
        {
          :title => "Post #{index}"
        }
      end

      client_mock.should_receive(:call).with("metaWeblog.getRecentPosts", 0, "admin", "wordpress-xmlrpc", 10).and_return(post_structs)

      recent_posts = blog.recent_posts(10)
      recent_posts.size.should == 10
      recent_posts[0].title.should == "Post 1"
    end
  end

end

