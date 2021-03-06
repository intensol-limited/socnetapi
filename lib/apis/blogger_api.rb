require "gdata"
require 'oauth2'

module Socnetapi
  class BloggerApi
    def initialize params = {}
      raise Socnetapi::Error::NotConnected unless params[:token]
      client = OAuth2::Client.new(params[:api_key], params[:api_secret], :site => 'http://www.blogger.com')
      @access_token = params[:token]
      @blogger  = OAuth2::AccessToken.from_hash(client, :access_token => params[:token])
    end
    
    def client
      r = @blogger.get("http://www.blogger.com/feeds/default/blogs?v=2&access_token=#{@access_token}")
      raise Socnetapi::Error::BadResponse unless r.is_a?(GData::HTTP::Response)
      p r.response.body
      @blogger
      rescue exception_block
    end
    
    def delete(id)
      edit_url = "http://gdata.blogger.com/feeds/api/users/default/uploads/#{id}"
      r = @blogger.delete(edit_url)
      raise Socnetapi::Error::BadResponse unless r.is_a?(GData::HTTP::Response)
      r
    rescue exception_block
    end


    def update(id, params = {})
      raise Socnetapi::Error::MissingId unless id
      edit_url = "http://gdata.blogger.com/feeds/api/users/default/uploads/#{id}"

      entry = %{<?xml version="1.0"?>
        <entry xmlns="http://www.w3.org/2005/Atom"
          xmlns:media="http://search.yahoo.com/mrss/"
          xmlns:yt="http://gdata.blogger.com/schemas/2007">
          <media:group>
            <media:title type="plain">#{params[:title]}</media:title>
            <media:description type="plain">#{params[:description]}</media:description>
            <media:category scheme="http://gdata.blogger.com/schemas/2007/categories.cat">People</media:category>
            <media:keywords>#{params[:tags]}</media:keywords>
          </media:group>
        </entry>}

      response = @blogger.put(edit_url, entry)
      
      raise Socnetapi::Error::BadResponse unless response.is_a?(GData::HTTP::Response)

      @doc = Nokogiri::XML(response.body)
      @doc.at('//yt:videoid').text rescue nil
    rescue exception_block
    end


    def create(file_path, params = {})
      feed = 'http://uploads.gdata.blogger.com/feeds/api/users/default/uploads'
      mime_type = ::MIME::Types.type_for(file_path).first.to_s
      entry = %{
      <entry xmlns="http://www.w3.org/2005/Atom"
        xmlns:media="http://search.yahoo.com/mrss/"
        xmlns:yt="http://gdata.blogger.com/schemas/2007">
        <media:group>
          <media:title type="plain">#{params[:title]}</media:title>
          <media:description type="plain">
            #{params[:description]}
          </media:description>
          <media:category
            scheme="http://gdata.blogger.com/schemas/2007/categories.cat">People
          </media:category>
          <media:keywords>#{params[:tags]}</media:keywords>
        </media:group>
      </entry>}
      response = @blogger.post_file(feed, file_path, mime_type, entry)

      raise Socnetapi::Error::BadResponse unless response.is_a?(GData::HTTP::Response)

      @doc = Nokogiri::XML(response.body)
      @doc.at('//yt:videoid').text rescue nil
    rescue exception_block
    end

    def exception_block
      raise $! if $!
    end
  end
end
