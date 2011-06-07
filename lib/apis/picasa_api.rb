require 'gdata'
require 'nokogiri'

module Socnetapi
  class PicasaApi
    def initialize params
      #raise Socnetapi::Error::NotConnected unless params[:token]
      @picasa = GData::Client::Photos.new
      
      @picasa.clientlogin(params['login'], params['password'])
    end
    
    def client
      @picasa
    end
    
    def get_entries
      url = "http://picasaweb.google.com/data/feed/api/user/default?access=private"
      response = @picasa.get(url)
      parse_entries response.body      
    end
        
    def get_entry id
      url = "http://picasaweb.google.com/data/feed/api/user/default/albumid/#{id}?access=private"
      response = @picasa.get(url)
      parse_entry response.body
    end
    
    def create
    end
    
    def update
    end
    
    def delete
    end
    
    def friends
    end
    
    protected
    
    def parse_entries xml
      doc = Nokogiri::XML(xml)
      
      doc.css('entry').map do |entry|
        get_entry entry.at_css('gphoto|id').text
      end
    end
    
    def parse_entry xml
      doc = Nokogiri::XML(xml)
      
      {
        id: doc.at_css('feed > gphoto|id').text,
        title: doc.at_css('feed > title').text,
        text: doc.at_css('feed > subtitle').text,
        attachments: {
          images: doc.css('entry').map{|entry| parse_photo entry }
        },
        author: {
          id: doc.at_css('feed > author > uri').text,
          name: doc.at_css('feed > author > name').text
        }
      }
    end    
    
    def parse_photo entry
      content = entry.at_css('media|group > media|content')
      {
        url: content[:url],
        width: content[:width],
        height: content[:height],
        type: content[:type]
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
