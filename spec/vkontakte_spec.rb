require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "socnetapi"))

describe Socnetapi::VkontakteApi do
  before do
    @config = YAML::load(File.open(File.join(File.dirname(__FILE__), "config.yml")))["vkontakte"]
    @vkontakte = Socnetapi::VkontakteApi.new :app_id => @config['app_id'], :api_key => @config['api_key']
		@uid = @config['uid']
		@access_token = @config['access_token'];
	end
  
  it "should get friends list" do
    @vkontakte.friends(@uid,@access_token).should_not be_nil
  end
  
  it "should get entries list" do
    @vkontakte.get_entries(@uid,@access_token).should_not be_nil
  end
  
   it "should create, update, delete entries and get entry by id" do
     entry_id = @vkontakte.create(@access_token,{:message => "Hello Facebook! #{Time.now}"})
     entry_id.should_not be_nil
     entry_id = @vkontakte.update(entry_id,@access_token, :message => "Hello World! #{Time.now}")
     entry_id.should_not be_nil
     @vkontakte.get_entry(@uid,entry_id,@access_token).should_not be_nil
     @vkontakte.delete(entry_id,@access_token)
     @vkontakte.get_entry(@uid,entry_id,@access_token).should be_nil
   end
end
