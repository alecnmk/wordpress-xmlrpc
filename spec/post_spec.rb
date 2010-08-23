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
                                 :title => "Post title",
                                 :content => "Post content",
                                 :excerpt => "Post excerpt",
                                 :publish_date => Date.parse("01.08.2010")
                                 )
      post.to_struct.should == {
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
end

