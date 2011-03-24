require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "socnetapi"))

describe Socnetapi::FacebookApi do
  before do
    @facebook = Socnetapi::FacebookApi.new
  end
  
  it "should get friends list" do
    @facebook.friends.should_not be_nil
  end
  
  it "should get entries list" do
    @facebook.entries.should_not be_nil
  end
  
  it "should create, update, delete entries and get entry by id" do
    entry_id = @facebook.create(:body => "Hello Facebook! #{Time.now}")
    entry_id.should_not be_nil
    entry_id = @facebook.update(entry_id, :body => "Hello World! #{Time.now}")
    entry_id.should_not be_nil
    @facebook.entry(entry_id).should_not be_nil
    @facebook.delete(entry_id)
    @facebook.entry(entry_id).should be_nil
  end
end