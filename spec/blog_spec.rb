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
      XMLRPC::Client.should_receive(:new2).with("http://localhost/xmlrpc.php").and_return(@client_mock)

      @blog = Wordpress::Blog.new(
                                   :blog_uri => "http://localhost",
                                   :user => "admin",
                                   :password => "wordpress-xmlrpc",
                                   :blog_id => 0
                                   )
    end

    describe "delete" do
      context "when post passed as param" do
        it "should make appropriate call to XMLRPC API" do
          @client_mock.should_receive(:call).with("blogger.deletePost", "", 123, "admin", "wordpress-xmlrpc", true).and_return(true)

          post = Wordpress::Post.new(:id => 123)
          @blog.delete(post).should be_true
        end
      end

      context "when page passed as param" do
        it "should make appropriate call to XMLRPC API" do
          @client_mock.should_receive(:call).with("wp.deletePage", 0, "admin", "wordpress-xmlrpc", 123).and_return(true)

          page = Wordpress::Page.new(:id => 123)
          @blog.delete(page).should be_true
        end
      end

    end

    describe "get_page_list" do
      it "should return list of pages" do
        page_structs = [
                        {
                          "page_id" => 1,
                          "page_title" => "Page one",
                          "page_parent_id" => 2,
                          "dateCreated" => Date.parse("01.08.2010")
                        },
                        {
                          "page_id" => 2,
                          "page_title" => "Page two",
                          "page_parent_id" => nil,
                          "dateCreated" => Date.parse("01.08.2010")
                        }
                       ]
        @client_mock.should_receive(:call).with("wp.getPageList", 0, "admin", "wordpress-xmlrpc").and_return(page_structs)

        page_two = Wordpress::Page.new(
                                       :id => 2,
                                       :title => "Page two",
                                       :creation_date => Date.parse("01.08.2010"),
                                       :parent => nil
                                       )
        page_one = Wordpress::Page.new(
                                       :id => 1,
                                       :title => "Page one",
                                       :creation_date => Date.parse("01.08.2010"),
                                       :parent_id => 2
                                       )
        page_list = [page_one, page_two]

        result_page_list = @blog.get_page_list
        result_page_list.size.should == 2

        result_page_list[0].id.should == 1
        result_page_list[0].title.should == "Page one"
        result_page_list[0].parent_id == 2
        result_page_list[0].parent.should == result_page_list[1]
        result_page_list[0].creation_date.should == Date.parse("01.08.2010")

        result_page_list[1].id.should == 2
        result_page_list[1].title.should == "Page two"
        result_page_list[1].parent_id.should be_nil
        result_page_list[1].creation_date.should == Date.parse("01.08.2010")

      end
    end

    describe "publish" do
      context "when Page passed as param" do
        it "should make appropriate calls to XMLRPC API" do
          images = [{:file_path => File.expand_path("./spec/support/files/post_picture.jpg")}]

          page = Wordpress::Page.new(
                                     :title => "new Page",
                                     :content => "Page content",
                                     :excerpt => "Page excerpt",
                                     :creation_date => Date.parse("01.08.2010"),
                                     :images => images
                                     )
          @client_mock.should_receive(:call).with("wp.newPage",
                                                  0, "admin", "wordpress-xmlrpc",
                                                  {
                                                    :title => "new Page",
                                                    :page_title => "new Page",
                                                    :description => "Page content",
                                                    :mt_excerpt => "Page excerpt",
                                                    :dateCreated => Date.parse("01.08.2010")
                                                  }, true).and_return(123)

          file_struct = {
            :name => "post_picture.jpg",
            :type => "image/jpeg",
            :bits => "encoded file content",
            :overwrite => true
          }
          @client_mock.should_receive(:call).with(
                                                  "wp.uploadFile",
                                                  0, "admin", "wordpress-xmlrpc",
                                                  file_struct).and_return({
                                                                  'file' => "post_picture.jpg",
                                                                  'url' => "http://localhost/post_picture.jpg",
                                                                  'type' => "image/jpeg"
                                                                })

          XMLRPC::Base64.should_receive(:new).and_return("encoded file content")


          @blog.publish(page).should be_true
          page.id.should == 123
        end
      end

      context "when Post passed as param" do
        it "should make appropriate call to XMLRPC API" do
          images = [{:file_path => File.expand_path("./spec/support/files/post_picture.jpg")}]
          post = Wordpress::Post.new(
                                     :title => "Hey ho",
                                     :content => "Content <img src=\"http://otherhost/post_picture.jpg?1231231123\">",
                                     :excerpt => "Excerpt",
                                     :images => images,
                                     :creation_date => Date.parse("01.08.2010"))


          required_post_struct = {
            :title => "Hey ho",
            :description => "Content <img src=\"http://localhost/post_picture.jpg\">",
            :mt_excerpt => "Excerpt",
            :dateCreated => Date.parse("01.08.2010")
          }


          file_struct = {
            :name => "post_picture.jpg",
            :type => "image/jpeg",
            :bits => "encoded file content",
            :overwrite => true
          }
          @client_mock.should_receive(:call).with(
                                                  "wp.uploadFile",
                                                  0, "admin", "wordpress-xmlrpc",
                                                  file_struct).and_return({
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
    end

    describe "recent_posts" do
      it "should make appropriate call to xmlrpc api and return list of posts" do
        post_structs = (1..10).collect do |index|
          {
            "title" => "Post #{index}"
          }
        end

        @client_mock.should_receive(:call).with(
                                                "metaWeblog.getRecentPosts",
                                                0, "admin", "wordpress-xmlrpc",
                                                10).and_return(post_structs)

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

    describe "update" do
      before(:each) do
        @images = [{:file_path => File.expand_path("./spec/support/files/post_picture.jpg")}]

      end

      context "when page passed as param" do
        it "should submit page update" do
          page = Wordpress::Page.new(
                                     :id => 123,
                                     :title => "Updated page",
                                     :content => "Content <img src=\"http://otherhost/post_picture.jpg\">",
                                     :published => true,
                                     :images => @images
                                     )
          required_page_struct = {
            :title => "Updated page",
            :page_title => "Updated page",
            :description => "Content <img src=\"http://localhost/post_picture.jpg\">",
            :page_id => 123
          }
          @client_mock.should_receive(:call).with("wp.editPage", 0, 123, "admin", "wordpress-xmlrpc", required_page_struct, true).and_return true
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

          @blog.update(page).should be_true
        end
      end

      context "when post passed as param" do
        it "should submit post update" do
          post = Wordpress::Post.new(
                                     :id => 54,
                                     :title => "Updated post",
                                     :content => "Content <img src=\"http://otherhost/post_picture.jpg\">",
                                     :published => true,
                                     :images => @images)

          required_post_struct = {
            :title => "Updated post",
            :description => "Content <img src=\"http://localhost/post_picture.jpg\">",
            :postid => 54,
            :post_state => "publish"
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

          @blog.update(post).should be_true
        end
      end
      end
  end
end

