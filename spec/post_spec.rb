require 'spec_helper'

describe Wordpress::Post do
  subject {Wordpress::Post}

  it_should_behave_like "Blog item"

  describe "matching attributes" do
    it "should match attributes as defined in metaWeblog API" do
      matches = Wordpress::Post::ATTRIBUTE_MATCHES[:metaWeblog]
      matches[:postid].should == :id
      matches[:title].should == :title
      matches[:description].should == :content
      matches[:mt_excerpt].should == :excerpt
      matches[:post_state].should == :struct_published
    end
    it "should not match for wp API at all" do
      matches = Wordpress::Post::ATTRIBUTE_MATCHES[:wp]
      matches.should be_empty
    end
  end

end

