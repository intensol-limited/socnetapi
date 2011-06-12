require 'bundler/setup'
require 'sinatra'
require 'oauth'

config = YAML::load_file 'spec/config.yml'

enable :sessions

get '/login_picasa' do
  @consumer = OAuth::Consumer.new('anonymous', 'anonymous', {
    :site => "https://www.google.com",
    :request_token_path => "/accounts/OAuthGetRequestToken",
    :access_token_path => "/accounts/OAuthGetAccessToken",
    :authorize_path => "/accounts/OAuthAuthorizeToken",
    :signature_method => 'HMAC-SHA1',
    :oauth_version => '1.0'
  })
  @request_token  = @consumer.get_request_token({:oauth_callback => "http://localhost:4567/picasa_callback"}, {:scope => "http://picasaweb.google.com/data/"})
  session[:request_token] = @request_token
  redirect @request_token.authorize_url
end

get '/picasa_callback' do
  @request_token = session[:request_token]
  @access_token = @request_token.get_access_token(:oauth_verifier=>params[:oauth_verifier])
  
  session[:access_token] = @access_token
  "Token: #{@access_token.token}<br />Secret: #{@access_token.secret}"
end

get '/login_youtube' do
  @consumer = OAuth::Consumer.new('anonymous', 'anonymous', {
    :site => "https://www.google.com",
    :request_token_path => "/accounts/OAuthGetRequestToken",
    :access_token_path => "/accounts/OAuthGetAccessToken",
    :authorize_path => "/accounts/OAuthAuthorizeToken",
    :signature_method => 'HMAC-SHA1',
    :oauth_version => '1.0'
  })
  @request_token  = @consumer.get_request_token({:oauth_callback => "http://localhost:4567/youtube_callback"}, {:scope => "http://gdata.youtube.com/"})
  session[:request_token] = @request_token
  redirect @request_token.authorize_url
end

get '/youtube_callback' do
  @request_token = session[:request_token]
  @access_token = @request_token.get_access_token(:oauth_verifier=>params[:oauth_verifier])
  
  session[:access_token] = @access_token
  "Token: #{@access_token.token}<br />Secret: #{@access_token.secret}"
end