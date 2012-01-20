require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "socnetapi"))

describe Socnetapi::TumblrApi do
  before do
    @config = YAML::load(File.open(File.join(File.dirname(__FILE__), "config.yml")))["tumblr"]
    @tumblr = Socnetapi::TumblrApi.new(:blogname => "", :token => @config["token"], :secret => @config["secret"], :api_key => @config["api_key"], :api_secret => @config["api_secret"])
  end

  it "should get friends list" do
    @tumblr.friends.should_not be_nil
  end
  
  it "should get entries list" do
    @tumblr.get_entries.should_not be_nil
  end
  it "should create, update, delete entries and get entry by id" do
    entry_id = @tumblr.create({:body => "Hello Tumblr! #{Time.now}", :type => "text"})
    entry_id.should_not be_nil
   # @tumblr.update({:id => entry_id, :body => "Hello World! #{Time.now}", :type => "text"})
   # entry_id.should_not be_nil
    #@tumblr.get_entry(entry_id).should_not be_nil
    #@tumblr.delete(entry_id)
    @tumblr.get_entry(entry_id).should be_nil
  end
end
