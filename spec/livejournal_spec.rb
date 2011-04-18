require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "socnetapi"))

describe Socnetapi::LivejournalApi do
  before do
    @config = YAML::load(File.open(File.join(File.dirname(__FILE__), "config.yml")))["livejournal"]
    @livejournal = Socnetapi::LivejournalApi.new(:login => @config["login"], :password => @config["password"])
  end
  
  it "should get friends list" do
    @livejournal.friends.should_not be_nil
  end
  
  it "should get entries list" do
    @livejournal.get_entries(3).should_not be_nil
  end
  
  it "should raise error on getting unexisting entry" do
    lambda { @livejournal.get_entry(-13) }.should raise_error
  end
  
  it "should create, update, delete entries and get entry by id" do
    entry_id = @livejournal.create(:body => "Hello LJ! #{Time.now}")
    entry_id.should_not be_nil
    entry_id = @livejournal.update(entry_id, :body => "Hello World! #{Time.now}")
    entry_id.should_not be_nil
    lambda { @livejournal.get_entry(entry_id) }.should_not raise_error
    @livejournal.get_entry(entry_id).should_not be_nil
    @livejournal.delete(entry_id)
    lambda { @livejournal.get_entry(entry_id) }.should raise_error
  end
end