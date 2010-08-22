require 'spec_helper'

describe Wordpress::Client do
  describe "publish!" do
    it "should raise ArgumentError if post is nil" do
      lambda{
        subject.publish!(nil)
      }.should raise_error
    end

    it "should raise ArgumentError if other class instance passed instead of Post" do
      lambda{
        subject.publish!("something else")
      }.should raise_error
    end
  end
end

