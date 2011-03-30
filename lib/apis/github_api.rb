require "oauth2"

module Socnetapi
  class GithubApi
    def initialize params = {}
      params[:api_key] ||= "6ce44feb0686fa5734e0"
      params[:api_secret] ||= "b91765291ecdefc6ea9dc82021099ab06ad8a9db"
      params[:token] = "2f9aad1b61e35b8eda0e"
      
      @client = OAuth2::Client.new(params[:api_key], params[:api_secret], :site => "https://github.com", :authorize_path => "/login/oauth/authorize", :access_token_path => "/login/oauth/access_token")
      @github = @client.web_server.get_access_token(params[:token])
    end
    
    def client
      @client
    end
    
    def github
      @github
    end
  end
end