require 'rubygems'
require 'bundler/setup'

require 'socnetapi'

describe Socnetapi::PicasaApi do
  
  before do
    @config = YAML::load(File.open(File.join(File.dirname(__FILE__), "config.yml")))["picasa"]
    @picasa = Socnetapi::PicasaApi.new(:token => @config[:token])
  end

  it "should get entries list" do
    @picasa.get_entries.should_not be_nil
  end
end
