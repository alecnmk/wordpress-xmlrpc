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

  describe "api calls" do
    before(:each) do
      @client_mock = mock("client")
      XMLRPC::Client.should_receive(:new2).with("http://localhost/xmlrpc").and_return(@client_mock)

      @blog = Wordpress::Blog.new(
                                   :blog_uri => "http://localhost",
                                   :user => "admin",
                                   :password => "wordpress-xmlrpc",
                                   :blog_id => 0
                                   )
    end

    describe "publish" do
      it "should make appropriate call to xmlrpc api" do
        images = [{:file_path => File.expand_path("./spec/support/files/post_picture.jpg")}]
        post = Wordpress::Post.new(
                                   :title => "Hey ho",
                                   :content => "Content <img src=\"http://otherhost/post_picture.jpg?1231231123\">",
                                   :excerpt => "Excerpt",
                                   :images => images,
                                   :publish_date => Date.parse("01.08.2010"))


        required_post_struct = {
          :title=>"Hey ho",
          :description=>"Content <img src=\"http://localhost/post_picture.jpg\">",
          :mt_excerpt=>"Excerpt"
        }

        @client_mock.should_receive(:call).with(
                                                "wp.uploadFile",
                                                0, "admin", "wordpress-xmlrpc",
                                                {
                                                  :name => "post_picture.jpg",
                                                  :type => "image/jpeg",
                                                  :bits => "encoded file content",
                                                  :overwrite => true
                                                }).and_return({
                                                               'file' => "post_picture.jpg",
                                                               'url' => "http://localhost/post_picture.jpg",
                                                               'type' => "image/jpeg"
                                                             })

        @client_mock.should_receive(:call).with(
                                                "metaWeblog.newPost",
                                                0, "admin", "wordpress-xmlrpc",
                                                required_post_struct, true).and_return("123")

        XMLRPC::Base64.should_receive(:new).and_return("encoded file content")

        @blog.publish(post).should be_true
        post.id.should == 123
        post.published.should be_true
      end
    end

    describe "recent_posts" do
      it "should make appropriate call to xmlrpc api and return list of posts" do
        post_structs = (1..10).collect do |index|
          {
            :title => "Post #{index}"
          }
        end

        @client_mock.should_receive(:call).with("metaWeblog.getRecentPosts", 0, "admin", "wordpress-xmlrpc", 10).and_return(post_structs)

        recent_posts = @blog.recent_posts(10)
        recent_posts.size.should == 10
        recent_posts[0].title.should == "Post 1"
      end
    end

    describe "get_post" do
      it "should return post for provided post_id" do
        post_struct = {
          :title => "Post title"
        }
        @client_mock.should_receive(:call).with("metaWeblog.getPost", 54, "admin", "wordpress-xmlrpc").and_return(post_struct)
        post = @blog.get_post(54)
        post.should_not be_nil
        post.title.should == "Post title"
      end
    end

    describe "update_post" do
      it "should submit post update" do
        images = [{:file_path => File.expand_path("./spec/support/files/post_picture.jpg")}]
        post = Wordpress::Post.new(:id => 54, :title => "Updated post", :content => "Content <img src=\"http://otherhost/post_picture.jpg\">",  :published => true, :images => images)

        required_post_struct = {
          :title=>"Updated post",
          :description=>"Content <img src=\"http://localhost/post_picture.jpg\">",
          :postid => 54
        }
        @client_mock.should_receive(:call).with("metaWeblog.editPost",
                                                54, "admin", "wordpress-xmlrpc",
                                                required_post_struct, true).and_return(true)

        @client_mock.should_receive(:call).with("wp.uploadFile",
                                                0, "admin", "wordpress-xmlrpc",
                                                {
                                                  :name => "post_picture.jpg",
                                                  :type => "image/jpeg",
                                                  :bits => "encoded file content",
                                                  :overwrite => true
                                                }).and_return({
                                                               'file' => "post_picture.jpg",
                                                               'url' => "http://localhost/post_picture.jpg",
                                                               'type' => "image/jpeg"
                                                             })
        XMLRPC::Base64.should_receive(:new).and_return("encoded file content")

        @blog.update_post(post).should be_true
      end
    end

  end
end

