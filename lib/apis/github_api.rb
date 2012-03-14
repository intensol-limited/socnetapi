require "oauth2"

module Socnetapi
  class GithubApi
    def initialize params = {}
      raise Socnetapi::Error::NotConnected unless params[:token]
      
      @client = OAuth2::Client.new(params[:api_key], params[:api_secret], :site => "https://github.com", :authorize_path => "/login/oauth/authorize", :access_token_path => "/login/oauth/access_token")
      @github = @client.web_server.get_access_token(params[:token])
    end
    
    def client
      @client
    rescue exception_block
    end
    
    def github
      @github
    rescue exception_block
    end

    def exception_block
      raise $! if $!
    end
  end
end