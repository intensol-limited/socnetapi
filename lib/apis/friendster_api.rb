require 'cgi'
require 'digest/md5'
module Socnetapi
  class FriendsterApi
    attr_accessor :api_key, :session_key, :auth_token, :user_id, :secret
    def initialize params
      @session_key = params[:session_key]
      @auth_token = params[:auth_token]
      @api_key = params[:api_key]
      @user_id = params[:user_id]
      @secret = params[:secret]
      
      get_session_key! if @session_key.nil?
    end
    
    def get_user_info user_id = nil
      prepare_user make_request('GET', "/user/#{user_id}")
    end
    
    def friends user_id = nil
      prepare_friends make_request('GET', "/friends/#{user_id}")
    end
    
    protected
    
    def get_session_key!
      response = make_signed_http_request('POST', '/v1/session', {
        'api_key' => @api_key,
        'auth_token' => @auth_token
      })
      doc = Nokogiri::XML(response.body)
      @session_key = (doc.root > 'session_key').text
    end
    
    def prepare_user response
      response
    end
    
    def prepare_friends response
      response.css('uid').map{|uid_node| get_user_info uid_node.text  }
    end
    
    def make_request method, resource, params=nil, data=nil
      params ||= {}
      path = '/v1' + resource
      params = params.merge('session_key' => @session_key, 'api_key' => @api_key, 'nonce' => (Time.now.to_f*1000_000).to_i)
      
      response = make_signed_http_request method, path, params, data
      
      doc = Nokogiri::XML(response.body)
      
      unless response.is_a? Net::HTTPSuccess
        if doc.root.name == "error_response"
          raise Socnetapi::Error::BadResponse.new((doc.root > 'error_message').text, (doc.root > 'error_code').text, response.code)
        else
          raise Socnetapi::Error::BadResponse.new(response.inspect)
        end
      end
      
      doc
    rescue Socnetapi::Error::BadResponse => e
      if e.code == '102'
        $stderr.puts e.to_s
        get_session_key!  
        retry
      else 
        raise e
      end
    end
    
    def make_signed_http_request method, path, params, data=nil
      params = sign path, params
      make_http_request method, path, params, data
    end
    
    def make_http_request method, path, params, data=nil
      params_string = params.map{|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"}.join("&")
      http = Net::HTTP.new 'api.friendster.com', 80
      http.set_debug_output($stderr)
      response = http.start do |http|
        http.send_request method, "#{path}?#{params_string}", data
      end
      response
    end
    
    def sign path, params      
      sig = Digest::MD5.hexdigest(path + (params.map{|k, v| [k.to_s, v.to_s] }.sort.map{|k,v| "#{k}=#{v}" }.join) + @secret)
      params['sig'] = sig
      params
    end
  end
end