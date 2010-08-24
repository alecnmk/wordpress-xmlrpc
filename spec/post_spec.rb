require 'spec_helper'

describe Wordpress::Post do
  describe "initialize" do
    it "should populate title from params" do
      post = Wordpress::Post.new(:title => "Hey ho")
      post.title.should == "Hey ho"
    end
    it "should populate content from params" do
      post = Wordpress::Post.new(:content => "This is a content")
      post.content.should == "This is a content"
    end
  end

  describe "to_struct" do
    it "should return struct hash reflecting all post params" do
      post = Wordpress::Post.new(
                                 :id => 99,
                                 :title => "Post title",
                                 :content => "Post content",
                                 :excerpt => "Post excerpt",
                                 :creation_date => Date.parse("01.08.2010")
                                 )
      post.to_struct.should == {
        :postid => 99,
        :title => "Post title",
        :description => "Post content",
        :mt_excerpt => "Post excerpt",
        :dateCreated => Date.parse("01.08.2010")
      }
    end
    it "should return incomplete struct for params without params that are nil" do
      post = Wordpress::Post.new(:title => "Post title")
      post.to_struct.should == {
        :title => "Post title"
      }
    end
  end

  describe "from_struct" do
    it "should create post from RPC struct" do
      post = Wordpress::Post.from_struct({
                                           :postid => 99,
                                           :title => "Post title",
                                           :description => "Post content",
                                           :mt_excerpt => "Post excerpt",
                                           :dateCreated => "01.08.2010",
                                           :post_state => "publish"
                                         })
      post.id.should == 99
      post.title.should == "Post title"
      post.content.should == "Post content"
      post.excerpt.should == "Post excerpt"
      post.creation_date.should == Date.parse("01.08.2010")
      post.published.should be_true
    end
  end

  describe "creation_date=" do
    before(:each) do
      @post = Wordpress::Post.new
    end

    it "should convert string to date" do
      @post.creation_date = "01.08.2010"
      @post.creation_date.should == Date.parse("01.08.2010")
    end

    it "should assign date as is if kind_of? Date provided" do
      date = Date.parse("01.08.2010")
      @post.creation_date = date
      @post.creation_date.should == date
    end

    it "should raise error if string could not be parsed to date" do
      lambda{
        @post.creation_date = "abracadabra"
      }.should raise_error ArgumentError, "invalid date"
    end

    it "should raise exception if object is not a string and not a date" do
      lambda{
        @post.creation_date = Integer(10)
      }.should raise_error ArgumentError, "Date or String expected instead of Fixnum"
    end
  end



end

