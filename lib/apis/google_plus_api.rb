require "oauth2"
require 'curb'

module Socnetapi
  class GooglePlusApi
    def self.get_credential(access_token)
      {
        :expires_at => access_token.expires_at,
        :expires_in => access_token.expires_in,
        :refresh_token => access_token.refresh_token
      }
    end

    def initialize params = {}
      @app_key = params[:app_key]
      @client = OAuth2::Client.new(params[:api_key], params[:api_secret], {:site => 'https://accounts.google.com', :authorize_url => '/o/oauth2/auth',  :token_url => '/o/oauth2/token'})
      #@googleplus = @client.web_server.get_access_token(params[:token])
    end

    def client
      @client
    end

    def app_key
      @app_key
    end

    def googleplus
      @googleplus
    end

    def get_entries(token)
      read_google_activities(token).inject([]) {|ret, elem| ret << {:id => elem['actor']['id'], :activity_id => elem['id'],:name => elem['actor']['displayName'], :name_link => elem['actor']['url'], :photo => elem['actor']['image']['url'] , :created_at => elem['published'], :text => elem['title'] , :text_link => elem['url'] , :attachments => elem['object']['attachments']}}
    end

    def check_and_update_google_token(extra_credentials)
      token = OAuth2::AccessToken.from_hash(client, extra_credentials.dup)
      update = token.expired?
      [ update,
        if update
          if extra_credentials[:refresh_token]
            c = Curl::Easy.http_post("https://accounts.google.com/o/oauth2/token", Curl::PostField.content('client_id', client.id), Curl::PostField.content('client_secret', client.secret), Curl::PostField.content('refresh_token', extra_credentials[:refresh_token]), Curl::PostField.content('grant_type', 'refresh_token'))
            c.perform
            data = JSON.parse(c.body_str)
            {
                :token => data['access_token'],
                :extra_credentials => (extra_credentials.merge(:expires_at => (Time.now.to_i + data['expired_in'].to_i)))
            }
          else
            raise "Refresh token is empty"
          end
        end
      ]
    end

    private
    def read_google_activities(token)
      c = Curl::Easy.new("https://www.googleapis.com/plus/v1/people/me/activities/public?alt=json&pp=1&key=#{app_key}&access_token=#{token}")
      c.perform
      JSON.parse(c.body_str)['items']
    end
  end
end