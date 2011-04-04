require "flickraw"

module Socnetapi
  class FlickrApi
    def initialize options = {}
      options[:api_key] ||= "85cc61cb0ceb5e69aee5679acfc82e73"
      options[:api_secret] ||= "6ebb6c07b04939b8"
      options[:uid] ||= "60866248@N05"
      options[:login] ||= "intensol"
      options[:auth_token] ||= "72157626325393628-b70130fda0ad504d"

      FlickRaw.api_key = options[:api_key]
      FlickRaw.shared_secret = options[:api_secret]
      @flickr = flickr
      @auth = flickr.auth.checkToken :auth_token => options[:auth_token]
    end
    
    def client
      @flickr
    end
    
    def auth
      @auth
    end
    
    def friends
      prepare_friends @flickr.contacts.getList
    end
    
    def get_entries
      prepare_entries @flickr.photos.getRecent
    end
    
    def get_entry id, secret = ''
      entry = @flickr.photos.getInfo(:photo_id => id.to_s, :secret => secret)
      {
        id: entry.id,
        author: {
          id: entry.owner["nsid"],
          name: entry.owner.realname,
          nickname: entry.owner.username
        },
        title: entry.title,
        text: entry.description,
        attachments: {
          images: [FlickRaw.url(entry)]
        },
        created_at: entry.dates.taken,
        url: FlickRaw.url_photopage(entry)
      }
    end
    
    def create params = {}
      # See http://www.flickr.com/services/api/upload.api.html for more information on the arguments.
      @flickr.upload_photo params[:file_path], {:title => params[:title], :description => params[:description]}
    end
    
    def update params = {}
      # See http://www.flickr.com/services/api/replace.api.html for more information on the arguments.
      @flickr.replace_photo params[:file_path], :photo_id => params[:photo_id]
    end
    
    def delete id
      @flickr.photos.delete :photo_id => id.to_s
    end
    
    private
    
    def prepare_friends friends
      friends.map do |friend|
        {
          id: friend["nsid"],
          nickname:  friend["username"],
          name: friend["realname"]
        }
      end
    end
    
    def prepare_entries entries
      entries.map do |entry|
        prepare_entry entry
      end
    end
    
    # {"id"=>"5588491245", "owner"=>"49650339@N07", "secret"=>"f084db399c", "server"=>"5188", "farm"=>6, "title"=>"Mex 2011 013", "ispublic"=>1, "isfriend"=>0, "isfamily"=>0} 
    def prepare_entry entry
      {
        id: entry.id,
        author: {
          id: entry.owner
        },
        title: entry.title,
        attachments: {
          images: [FlickRaw.url(entry)]
        },
        url: FlickRaw.url_photopage(entry)
      }
    end
      
  end
end