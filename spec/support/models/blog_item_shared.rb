shared_examples_for "Blog item" do
  before(:each) do
    @api_standard = subject == Wordpress::Post ? :metaWeblog : :wp
  end



  describe "initialize" do
    it "should populate title from params" do
      item = subject.new(:title => "Hey ho")
      item.title.should == "Hey ho"
    end
    it "should populate content from params" do
      item = subject.new(:content => "This is a content")
      item.content.should == "This is a content"
    end
  end

  describe "to_struct" do
    it "should return struct hash reflecting matching item params" do
      item = subject.new(
                         :content => "item content",
                         :excerpt => "item excerpt",
                         :creation_date => Date.parse("01.08.2010")
                         )
      item.to_struct(@api_standard).should == {
        :description => "item content",
        :mt_excerpt => "item excerpt",
        :dateCreated => Date.parse("01.08.2010")
      }
    end

    it "should return incomplete struct for params without params that are nil" do
      item = subject.new(:content => "item content")
      item.to_struct(@api_standard).should == {
        :description => "item content"
      }
    end
  end

  describe "from_struct" do
    it "should create item from RPC struct" do
      item = subject.from_struct(@api_standard,
                                 {
                                   :description => "item content",
                                   :mt_excerpt => "item excerpt",
                                   :dateCreated => "01.08.2010"
                                 })
      item.content.should == "item content"
      item.excerpt.should == "item excerpt"
      item.creation_date.should == Date.parse("01.08.2010")
    end
  end

  describe "creation_date=" do
    before(:each) do
      @item = subject.new
    end

    it "should convert string to date" do
      @item.creation_date = "01.08.2010"
      @item.creation_date.should == Date.parse("01.08.2010")
    end

    it "should assign date as is if kind_of? Date provided" do
      date = Date.parse("01.08.2010")
      @item.creation_date = date
      @item.creation_date.should == date
    end

    it "should raise error if string could not be parsed to date" do
      lambda{
        @item.creation_date = "abracadabra"
      }.should raise_error ArgumentError, "invalid date"
    end

    it "should raise exception if object is not a string and not a date" do
      lambda{
        @item.creation_date = Integer(10)
      }.should raise_error ArgumentError, "Date or String expected instead of Fixnum"
    end
  end



end
