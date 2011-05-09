require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "socnetapi"))

describe Socnetapi::VimeoApi do
  before do
    @config = YAML::load(File.open(File.join(File.dirname(__FILE__), "config.yml")))["vimeo"]
    @vimeo = Socnetapi::VimeoApi.new(:api_key => @config["api_key"],
                                       :api_secret => @config["api_secret"],
                                       :token => @config["token"],
                                       :secret => @config["secret"],
                                       :user_id => @config["user_id"])
  end
  
  # it "should get friends list" do
  #   @vimeo.friends.should_not be_nil
  # end
  # 
  # it "should get entries list" do
  #   entries = @vimeo.get_entries
  #   entries.should_not be_nil
  # end
  
  # it "should get entry info" do
  #   @vimeo.get_entry("16087562").should_not be_nil
  # end
  
  # it "should upload and delete video" do
  #   entry_id = nil
  #   create_test_string = "Hello vimeo!"
  #   create_test_tags = 'test, hello'
  #   
  #   file_path = File.dirname(__FILE__) + '/video.avi'
  #   lambda {
  #     entry_id = @vimeo.create(file_path, {:title => create_test_string, :description => create_test_string, :tags => create_test_tags})
  #     entry_id.should_not be_nil
  #   }.should_not raise_error
  #   
  #   lambda {
  #     entry = @vimeo.get_entry(entry_id)
  #     entry.should_not be_nil
  #     entry[:title].should == create_test_string
  #     entry[:description].should == create_test_string
  #     entry[:tags].should == create_test_tags
  #   }.should_not raise_error
  #   
  #   lambda {
  #     @vimeo.delete(entry_id)
  #   }.should_not raise_error
  # end
  # 
  # it "should update video" do
  #   update_test_string = "Hello world! #{Time.now}"
  #   update_test_tags = "updated"
  #   entry_id = nil
  #   
  #   lambda {
  #     entry_id = @vimeo.user_entries.first[:id]
  #   }.should_not raise_error
  #   
  #   lambda {
  #     entry_id = @vimeo.update(entry_id, {:title => update_test_string, :description => update_test_string, :tags => update_test_tags})
  #     entry_id.should_not be_nil
  # 
  #     entry = @vimeo.get_entry(entry_id)
  #     entry.should_not be_nil
  #     entry[:title].should == update_test_string
  #     entry[:description].should == update_test_string
  #     entry[:tags].should == update_test_tags
  #   }.should_not raise_error
  # end
end