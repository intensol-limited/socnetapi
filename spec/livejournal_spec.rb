require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "socnetapi"))

describe Socnetapi::LivejournalApi do
  before do
    @livejournal = Socnetapi::LivejournalApi.new(:login => "intensoldev", :password => "qq112233")
  end
  
  it "should get friends list" do
    @livejournal.friends.should_not be_nil
  end
  
  it "should get entries list" do
    @livejournal.entries(3).should_not be_nil
  end
  
  it "should raise error on getting unexisting entry" do
    lambda { @livejournal.entry(-13) }.should raise_error
  end
  
  it "should create, update, delete entries and get entry by id" do
    entry_id = @livejournal.create(:body => "Hello LJ! #{Time.now}")
    entry_id.should_not be_nil
    entry_id = @livejournal.update(entry_id, :body => "Hello World! #{Time.now}")
    entry_id.should_not be_nil
    lambda { @livejournal.entry(entry_id) }.should_not raise_error
    @livejournal.entry(entry_id).should_not be_nil
    @livejournal.delete(entry_id)
    lambda { @livejournal.entry(entry_id) }.should raise_error
  end
end