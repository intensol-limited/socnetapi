require "gdata"

module Socnetapi
  class YoutubeApi
    def initialize params = {}
      params[:api_key] ||= 'www.tuppy.com'
      params[:api_secret] ||= 'nbAWcAiDe0pZThE4ZWoqJEw8'
      params[:token] ||= '1/hFDsKMztAc-0xw45T7meix9LWpOxk6KLHpP6wJ2soqw'
      params[:token_secret] ||= '2p1gjHR1t90csXWq4FLbUz8E'
      params[:login] ||= 'intensoldev'
      raise Socnetapi::Error::NotConnected unless params[:token]

      @youtube = GData::Client::YouTube.new
      @youtube.developer_key = 'AI39si4vwXwDLR5MrtsdR1ULUD8__EnEccla-0bnqV40KpeFDIyCwEv0VJqZKHUsO3MvVM_bXHp3cAr55HmMYMhqfxzLMUgDXA'
      @youtube.oauth! params[:api_key], params[:api_secret]
      @youtube.authorize_from_access params[:token], params[:token_secret]
    end
    
    def client
      @youtube
    end
    
    def friends
      @youtube.get('https://www.google.com/m8/feeds/contacts/default/full?max-results=10000').body
    end
    
    def user_entries
      url = "http://gdata.youtube.com/feeds/api/users/default/uploads"
      parse_entries(@youtube.get(url).body)
    end
    
    def delete(id)
      edit_url = "http://gdata.youtube.com/feeds/api/users/default/uploads/#{id}"
      @youtube.delete(edit_url)
    end


    def update(id, params = {})
      raise Socnetapi::Error::MissingId unless id
      edit_url = "http://gdata.youtube.com/feeds/api/users/default/uploads/#{id}"

      entry = %{<?xml version="1.0"?>
        <entry xmlns="http://www.w3.org/2005/Atom"
          xmlns:media="http://search.yahoo.com/mrss/"
          xmlns:yt="http://gdata.youtube.com/schemas/2007">
          <media:group>
            <media:title type="plain">#{params[:title]}</media:title>
            <media:description type="plain">#{params[:description]}</media:description>
            <media:category scheme="http://gdata.youtube.com/schemas/2007/categories.cat">People</media:category>
            <media:keywords>#{params[:tags]}</media:keywords>
          </media:group>
        </entry>}

      response = @youtube.put(edit_url, entry)
      
      raise Socnetapi::Error::BadResponse unless response.is_a?(GData::HTTP::Response)

      @doc = Nokogiri::XML(response.body)
      @doc.at('//yt:videoid').text rescue nil
    end


    def create(file_path, params = {})
      feed = 'http://uploads.gdata.youtube.com/feeds/api/users/default/uploads'
      mime_type = ::MIME::Types.type_for(file_path).first.to_s
      entry = %{
      <entry xmlns="http://www.w3.org/2005/Atom"
        xmlns:media="http://search.yahoo.com/mrss/"
        xmlns:yt="http://gdata.youtube.com/schemas/2007">
        <media:group>
          <media:title type="plain">#{params[:title]}</media:title>
          <media:description type="plain">
            #{params[:description]}
          </media:description>
          <media:category
            scheme="http://gdata.youtube.com/schemas/2007/categories.cat">People
          </media:category>
          <media:keywords>#{params[:tags]}</media:keywords>
        </media:group>
      </entry>}
      response = @youtube.post_file(feed, file_path, mime_type, entry)

      raise Socnetapi::Error::BadResponse unless response.is_a?(GData::HTTP::Response)

      @doc = Nokogiri::XML(response.body)
      @doc.at('//yt:videoid').text rescue nil
    end

    def entries
      url = "http://gdata.youtube.com/feeds/api/users/default/newsubscriptionvideos"
      parse_entries(@youtube.get(url).body)
    end
    
    def entry id
      url = "http://gdata.youtube.com/feeds/api/videos/#{id}?v=2"
      parse_entry_from_xml(@youtube.get(url).body)
    end
    
    private
    
    def parse_entries xml
      @doc = Nokogiri::XML(xml)
      @doc.css('entry').map do |entry|
        parse_entry entry
      end
    end
    
    def parse_entry_from_xml xml
      @doc = Nokogiri::XML(xml)
      parse_entry @doc.at_css('entry')
    end
    
    # Entry is a Nokogiri node
    def parse_entry entry
      group_node = entry.at('//media:group')
      if id_tag = entry.at('//yt:videoid')
        id = id_tag.text
      else 
        id = parse_entry_id(entry.at_css('id').text)
      end
      
      {
        id: id,
        created_at: entry.at_css('published').text,
        title: entry.at_css('title').text,
        description: group_node.at('//media:description').text,
        tags: group_node.at('//media:keywords').text,
        author: entry.at_css('author name').text,
        thumb: group_node.search('//media:thumbnail').last['url'],
        url: group_node.search('//media:content').first['url']
      }
    end
    
    def parse_entry_id string
      string.split("/").last
    end
  end
end