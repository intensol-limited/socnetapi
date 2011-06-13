require 'bundler/setup'
require 'sinatra'
require 'oauth'
require 'cgi'
require 'nokogiri'

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

get '/login_friendster' do
  url = "http://www.friendster.com/widget_login.php?api_key=#{config['friendster'][:api_key]}"
  redirect url
end

get '/friendster_callback' do
  url = 'http://api.friendster.com/v1/session'
  auth_token = params['auth_token']
  session_params = {
    'auth_token' => params['auth_token'],
    'api_key' => config['friendster'][:api_key]
  }
  normalized_params = session_params.keys.sort.map{|k| "#{k}=#{session_params[k]}" }.join
  sig = Digest::MD5.hexdigest(normalized_params + config['friendster'][:secret])
  session_params['sig'] = sig
  response = Net::HTTP.start('api.friendster.com', 80){|http|
    http.post('/v1/session?' + session_params.map{|k,v| "#{k}=#{v}" }.join("&"), '')
  }
  doc = Nokogiri::XML(response.body)
  user_id = (doc.root > 'uid').text
  session_key = (doc.root > 'session_key').text
  
  
  "<dl><dt>Session Key:<dt><dd>#{session_key}</dd><dt>User ID:</dt><dd>#{user_id}</dd></dl>"
  
end