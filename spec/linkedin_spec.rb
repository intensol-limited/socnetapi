require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "socnetapi"))

describe Socnetapi::LinkedinApi do
  before do
    @config = YAML::load(File.open(File.join(File.dirname(__FILE__), "config.yml")))["linkedin"]
    @linkedin = Socnetapi::LinkedinApi.new(:token => @config["token"], :secret => @config["secret"], :api_key => @config["api_key"], :api_secret => @config["api_secret"])
  end
  
  it "should get friends list" do
   @linkedin.friends.should_not be_nil
  end
 
  it "should get entries list" do
    e = @linkedin.get_entries
    p e
    e.should_not be_nil
  end
  
  it "should create, update, delete entries and get entry by id" do
    entry_id = @linkedin.create(:body => "Hello linkedin! #{Time.now}")
    entry_id.should_not be_nil
    entry_id = @linkedin.update(:body => "Hello World! #{Time.now}")
    entry_id.should_not be_nil
    @linkedin.delete
  end
end
