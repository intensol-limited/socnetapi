require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "socnetapi"))

describe Socnetapi::FlickrApi do
  before do
    @flickr = Socnetapi::FlickrApi.new
  end
  
  it "should get friends list" do
    lambda { @flickr.friends }.should_not raise_error
  end
  
  it "should get entries list" do
    @flickr.entries.should_not be_nil
  end
  
  it "should create, update, delete entries and get entry by id" do
    path = File.dirname(__FILE__) + '/image.jpg'
    entry_id = info = nil
    
    lambda {
      entry_id = @flickr.create :file_path => path, :title => "Hello Flickr!", :description => "Hello Flickr!"
    }.should_not raise_error
    
    lambda {
     info = @flickr.entry entry_id
    }.should_not raise_error

    info.title.should == "Hello Flickr!"
    info.description.should == "Hello Flickr!" 
    
    lambda {
      entry_id = @flickr.create :file_path => path, :title => "Hello World!", :description => "Hello World!"
    }.should_not raise_error
    
    lambda {
     info = @flickr.entry entry_id
    }.should_not raise_error

    info.title.should == "Hello World!"
    info.description.should == "Hello World!"

    lambda { @flickr.delete entry_id }.should_not raise_error
  end
end