require 'spec_helper'

describe Wordpress::Page do
  subject {Wordpress::Page}

  it_should_behave_like "Blog item"

  describe "matching attributes" do
    it "should match attributes as defined in wp API" do
      matches = Wordpress::Page::ATTRIBUTE_MATCHES[:wp]
      matches[:page_id].should == :id
      matches[:title].should == :title
      matches[:description].should == :content
      matches[:mt_excerpt].should == :excerpt
      matches[:dateCreated].should == :creation_date
      matches[:page_status].should == :status
      matches[:page_parent_id].should == :parent_id
    end

    it "should not match for metaWeblog API at all" do
      matches = Wordpress::Page::ATTRIBUTE_MATCHES[:metaWeblog]
      matches.should be_empty
    end
  end

end
