require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "socnetapi"))

describe Socnetapi::TwitterApi do
  before do
    @twitter = Socnetapi::TwitterApi.new(:token => "254122908-fC4Beod5q3mhzmjXScBGtb1cZoPcYaN8JwWY7uT9", :token_secret => "LsMGzPHsQkAV49o2oc46HxRkuaU8nYYY3lLiURS988")
  end
  
  it "should get friends list" do
    @twitter.friends.should_not be_nil
  end
  
  it "should get entries list" do
    @twitter.get_entries.should_not be_nil
  end
  
  it "should create, update, delete entries and get entry by id" do
    entry_id = @twitter.create(:body => "Hello Twitter! #{Time.now}")
    entry_id.should_not be_nil
    entry_id = @twitter.update(entry_id, :body => "Hello World! #{Time.now}")
    entry_id.should_not be_nil
    @twitter.get_entry(entry_id).should_not be_nil
    @twitter.delete(entry_id)
    @twitter.get_entry(entry_id).should be_nil
  end
end