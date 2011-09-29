require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "socnetapi"))
require "mime/types"

describe Socnetapi::WordpressApi do
  before do
    @config = YAML::load(File.open(File.join(File.dirname(__FILE__), "config.yml")))["wordpress"]
    @wordpress = Socnetapi::WordpressApi.new(:login => @config["login"], :password => @config["password"], :blog_url => @config["blog_url"])
  end
  
  it "should connect to blogger" do
    @wordpress.client.should_not be_nil
  end
  
  it "should get create,update and delete post" do
    entry_id = @wordpress.create(:body => "Hello Wordpress! #{Time.now}", :title => "Test")
    entry_id.should_not be_nil 
    @wordpress.update(entry_id, :body => "Hello, World! #{Time.now}", :title => "Update test").should_not be_nil
    @wordpress.delete(entry_id).should_not be_nil
  end
  
end
