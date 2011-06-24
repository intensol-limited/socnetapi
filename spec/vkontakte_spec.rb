require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "socnetapi"))

describe Socnetapi::VkontakteApi do
  before do
    @config = YAML::load(File.open(File.join(File.dirname(__FILE__), "config.yml")))["vkontakte"]
		@uid = @config['uid']
		@access_token = @config['access_token'];
    @vkontakte = Socnetapi::VkontakteApi.new :app_id => @config['app_id'], :api_key => @config['api_key'], :uid => @uid, :access_token => @access_token
	end
  
  it "should get friends list" do
    @vkontakte.friends.should_not be_nil
  end
  
  it "should get entries list" do
    @vkontakte.get_entries.should_not be_nil
  end
  
   it "should create, update, delete entries and get entry by id" do
     entry_id = @vkontakte.create(:message => "Hello Facebook! #{Time.now}")
     entry_id.should_not be_nil
     entry_id = @vkontakte.update(entry_id, :message => "Hello World! #{Time.now}")
     entry_id.should_not be_nil
     @vkontakte.get_entry(entry_id).should_not be_nil
     @vkontakte.delete(entry_id)
     @vkontakte.get_entry(entry_id).should be_nil
   end
end
