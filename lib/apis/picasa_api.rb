require 'gdata'
require 'nokogiri'
require 'mime/types'

module Socnetapi
  class PicasaApi
    def initialize params
      #raise Socnetapi::Error::NotConnected unless params[:token]
      @picasa = GData::Client::Photos.new :version => 2
      
      @picasa.oauth! params[:api_key], params[:api_secret]
      @picasa.authorize_from_access params[:token], params[:secret]
    end
    
    def client
      @picasa
    end
    
    def get_entries
      url = "https://picasaweb.google.com/data/feed/api/user/default?access=private"
      response = @picasa.get(url)
      parse_entries response.body
    end
        
    def get_entry id
      url = "https://picasaweb.google.com/data/entry/api/user/default/albumid/#{id}?access=private"
      response = @picasa.get(url)
      parse_entry response.body
    end
    
    def create album
      
      url = "https://picasaweb.google.com/data/feed/api/user/default" 
      
      xml = <<XML
      <entry xmlns='http://www.w3.org/2005/Atom'
          xmlns:media='http://search.yahoo.com/mrss/'
          xmlns:gphoto='http://schemas.google.com/photos/2007'>
        <title type='text'>#{album[:title]}</title>
        <summary type='text'>#{album[:text]}</summary>
        <gphoto:timestamp>#{Time.now.to_i*1000}</gphoto:timestamp>
        <category scheme='http://schemas.google.com/g/2005#kind'
          term='http://schemas.google.com/photos/2007#album'></category>
      </entry>
XML
      
      response = @picasa.post(url, xml)
      parse_entry response.body
    end
    
    
    def update album
      url = album[:edit_url]

      xml = <<XML
      <entry xmlns='http://www.w3.org/2005/Atom'
          xmlns:media='http://search.yahoo.com/mrss/'
          xmlns:gphoto='http://schemas.google.com/photos/2007'>
        <title type='text'>#{album[:title]}</title>
        <summary type='text'>#{album[:text]}</summary>
        <gphoto:location>Italy</gphoto:location>
        <gphoto:access>public</gphoto:access>
        <gphoto:timestamp>#{Time.now.to_i*1000}</gphoto:timestamp>
        <media:group>
          <media:keywords>italy, vacation</media:keywords>
        </media:group>
        <category scheme='http://schemas.google.com/g/2005#kind'
          term='http://schemas.google.com/photos/2007#album'></category>
      </entry>
XML
      
      @picasa.headers["If-Match"] = album[:etag]
      
      response = @picasa.put(url, xml)
      parse_entry response.body
    end
    
    def delete album
      @picasa.headers["If-Match"] = album[:etag]
      @picasa.delete album[:edit_url]
      album
    end
    
    def get_photos album
      url = "https://picasaweb.google.com/data/feed/api/user/#{album[:author][:id]}/albumid/#{album[:id]}"
      response = @picasa.get url
      parse_photos response.body
    end
    
    def add_photo album, photo, file_path
      url = "https://picasaweb.google.com/data/feed/api/user/#{album[:author][:id]}/albumid/#{album[:id]}"
      mime_type = ::MIME::Types.type_for(file_path).first.to_s
      entry = %{
      <entry xmlns='http://www.w3.org/2005/Atom'>
        <title>#{photo[:title]}</title>
        <summary>#{photo[:text]}</summary>
        <category scheme="http://schemas.google.com/g/2005#kind"
          term="http://schemas.google.com/photos/2007#photo"/>
      </entry>
      }
      @picasa.post_file(url, file_path, mime_type, entry)
    end
    
    def remove_photo photo
      url = photo[:edit_url]
      @picasa.headers["If-Match"] = photo[:etag]
      @picasa.delete(url)
    end
    
    def friends
      url = "https://picasaweb.google.com/data/feed/api/user/default/contacts?kind=user"
      parse_friends @picasa.get(url).body
    end
    
    protected
    
    def parse_friends xml
      doc = Nokogiri::XML(xml)
      doc.css('entry').map {|entry|
        parse_friend entry
      }
        
    end
    
    def parse_friend node
      {
        id: (node > 'gphoto|user').text,
        name: (node > 'gphoto|nickname').text,
        userpic: (node > 'gphoto|thumbnail').text,
        nickname: (node > 'gphoto|user').text
      }
    end
        
    def parse_entries xml
      doc = Nokogiri::XML(xml)
      doc.css('entry').map do |node|
        parse_entry_node node
      end
    end
    
    def parse_entry xml
      doc = Nokogiri::XML(xml)
      node = doc.root
      parse_entry_node node
    end
    
    def parse_entry_node node
      {
        id: (node > "gphoto|id").text,
        title: (node > "title").text,
        text: (node > "summary").text,
        author: {
          id: (node > "gphoto|user").text,
          name: (node > "author > name").text
        },
        edit_url: (node > 'link[rel=edit]').first['href'],
        etag: node['etag'],
      }
    end
    
    def parse_photos xml
      doc = Nokogiri::XML(xml)
      doc.css('entry').map{|entry| parse_photo entry }
    end
        
    def parse_photo entry
      content = entry.at_css('media|group > media|content')
      {
        id: (entry > 'gphoto|id').text,
        title: (entry > 'title').text,
        text: (entry > 'summary').text,
        album_id: (entry > 'gphoto|albumid').text,
        author: {
          id: (entry > 'author > gphoto|user').text,
          name: (entry > 'author > name').text
        },
        url: content[:url],
        width: content[:width],
        height: content[:height],
        type: content[:type],
        edit_url: (entry > 'link[rel=edit]').first['href'],
        etag: entry['etag']
      }
    end
    
    def create_albums_from_xml(xml_response)
      albums = []
      #response_hash = XmlSimple.xml_in(xml_response, { 'ForceArray' => false })
      #puts response_hash.inspect

      Picasa.entries(xml_response).each do |entry|
        #parse the entry xml element and get the album object
        album = Picasa.parse_album_entry(entry)

        #enter session values in album object
        album.picasa_session = PicasaSession.new
        album.picasa_session.auth_key = self.picasa_session.auth_key
        album.picasa_session.user_id = self.picasa_session.user_id

        albums << album
      end
    
      return albums
    end
    
  end
end
