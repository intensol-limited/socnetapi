require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "socnetapi"))

describe Socnetapi::PhotobucketApi do
  before do
    @config = YAML::load(File.open(File.join(File.dirname(__FILE__), "config.yml")))["twitter"]
    @pb = Socnetapi::PhotobucketApi.new(:token => @config["token"], :secret => @config["secret"], :api_key => @config["api_key"], :api_secret => @config["api_secret"])
  end
  
  it "should work" do
    lambda {
      res = @pb.connection.get("http://api.photobucket.com/ping?format=json")
      p res.body
    }.should_not raise_error
    
  end
  
  # it "should get friends list" do
  #   @twitter.friends.should_not be_nil
  # end
  # 
  # it "should get entries list" do
  #   @twitter.get_entries.should_not be_nil
  # end
  # 
  # it "should create, update, delete entries and get entry by id" do
  #   entry_id = @twitter.create(:body => "Hello Twitter! #{Time.now}")
  #   entry_id.should_not be_nil
  #   entry_id = @twitter.update(entry_id, :body => "Hello World! #{Time.now}")
  #   entry_id.should_not be_nil
  #   @twitter.get_entry(entry_id).should_not be_nil
  #   @twitter.delete(entry_id)
  #   @twitter.get_entry(entry_id).should be_nil
  # end
end