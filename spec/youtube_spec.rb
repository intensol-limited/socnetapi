require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "socnetapi"))
require "mime/types"

describe Socnetapi::YoutubeApi do
  before do
    @config = YAML::load(File.open(File.join(File.dirname(__FILE__), "config.yml")))["youtube"]
    @youtube = Socnetapi::YoutubeApi.new(:developer_key => @config["developer_key"], 
                                         :api_key => @config["api_key"],
                                         :api_secret => @config["api_secret"],
                                         :token => @config["token"],
                                         :secret => @config["secret"])
  end
  
  # it "should get friends list" do
  #   @youtube.friends.should_not be_nil
  # end
  
  it "should get entries list" do
    entries = @youtube.get_entries
    pp entries
    entries.should_not be_nil
  end
  # 
  # it "should upload and delete video" do
  #   entry_id = nil
  #   create_test_string = "Hello youtube!"
  #   create_test_tags = 'test, hello'
  #   
  #   file_path = File.dirname(__FILE__) + '/video.avi'
  #   lambda {
  #     entry_id = @youtube.create(file_path, {:title => create_test_string, :description => create_test_string, :tags => create_test_tags})
  #     entry_id.should_not be_nil
  #   }.should_not raise_error
  #   
  #   lambda {
  #     entry = @youtube.entry(entry_id)
  #     entry.should_not be_nil
  #     entry[:title].should == create_test_string
  #     entry[:description].should == create_test_string
  #     entry[:tags].should == create_test_tags
  #   }.should_not raise_error
  #   
  #   lambda {
  #     @youtube.delete(entry_id)
  #   }.should_not raise_error
  # end
  # 
  # it "should update video" do
  #   update_test_string = "Hello world! #{Time.now}"
  #   update_test_tags = "updated"
  #   entry_id = nil
  #   
  #   lambda {
  #     entry_id = @youtube.user_entries.first[:id]
  #   }.should_not raise_error
  #   
  #   lambda {
  #     entry_id = @youtube.update(entry_id, {:title => update_test_string, :description => update_test_string, :tags => update_test_tags})
  #     entry_id.should_not be_nil
  # 
  #     entry = @youtube.entry(entry_id)
  #     entry.should_not be_nil
  #     entry[:title].should == update_test_string
  #     entry[:description].should == update_test_string
  #     entry[:tags].should == update_test_tags
  #   }.should_not raise_error
  # end
end