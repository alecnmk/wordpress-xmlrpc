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
end

