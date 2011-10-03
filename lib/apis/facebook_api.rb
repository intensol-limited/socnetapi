require "koala"

module Socnetapi
  class FacebookApi
    def initialize params = {}
      raise Socnetapi::Error::NotConnected unless params[:token]
#      (Koala::HTTPService.http_options[:ssl] ||= {})[:ca_path] = '/usr/lib/ssl/certs/' 
#      (Koala::HTTPService.http_options[:ssl] ||= {})[:ca_file] = 'ca-certificates.crt'
      @facebook = Koala::Facebook::API.new(params[:token],)
    end
    
    def friends
      prepare_friends(@facebook.get_connections("me", "friends")) rescue []
    end
    
    def get_entries
      prepare_entries(@facebook.get_connections("me", "home")) rescue []
    end
    
    def get_entry id
      prepare_entry(@facebook.get_object(id))
    end
    
    def create params = {}
      res = @facebook.put_wall_post(params[:body], params[:attachments] ? params[:attachments] : {})
      res["id"]
    end
    
    def delete id
      @facebook.delete_object(id)
    end
    
    def update id, params = {}
      @facebook.delete_object(id)
      res = @facebook.put_wall_post(params[:body])
      res["id"]
    end
    
    private
    
    # id: 1056227917_193040020731897
    # from: 
    #   name: Yevgeniy Ikhelzon
    #   id: "1056227917"
    # message: "..."
    # picture: http://external.ak.fbcdn.net/safe_image.php?d=4487dc4100c768685974c736080fd1a8&w=90&h=90&url=http%3A%2F%2Fs.kyivpost.ua%2Fimages%2Fstory_thumb%2Fdata%2Fuploads%2Fc%2Fiblock%2Fru_articles%2F89953%2F4030.jpg
    # link: http://www.kyivpost.ua/ukraine/news/kolomojskij-ni-odna-gazeta-po-kievski-ne-vyjdet-poka-ne-ujdet-glavred.html
    # name: "..."
    # caption: www.kyivpost.ua
    # description: "..."
    # icon: http://static.ak.fbcdn.net/rsrc.php/v1/yD/r/aS8ecmYRys0.gif
    # actions: 
    # - name: Comment
    #   link: http://www.facebook.com/1056227917/posts/193040020731897
    # - name: Like
    #   link: http://www.facebook.com/1056227917/posts/193040020731897
    # type: link
    # created_time: 2011-03-30T13:36:55+0000
    # updated_time: 2011-03-30T13:36:55+0000
    def prepare_entry entry
      return unless entry
      {
        id: entry["id"],
        author: {
          id: entry["from"]["id"],
          name: entry["from"]["name"],
          userpic: @facebook.get_picture(entry["from"]["id"])
        },
        title: entry["name"],
        text: entry["message"],
        attachments: {
					thumbnails: entry["picture"] ? [entry["picture"]] : [],
          images: entry["type"] == "photo" ? [@facebook.get_picture(entry["object_id"])] : [],
					videos: (entry["type"] == "video" || entry["type"] == "swf") ? [entry["link"]] : [],
					link: {
						name: entry["name"],
						description: entry["description"],
						caption: entry["caption"] 
					}

        },
				type: entry["type"],
				link: entry["link"],
        created_at: entry["created_at"]
      }
    end
    
    def prepare_entries entries
      entries.map do |entry|
        prepare_entry entry
      end
    end
    
    def prepare_friends friends
      friends.map do |friend|
        {
          id: friend["id"],
          name: friend["name"],
          userpic: @facebook.get_picture(friend["id"])
        }
      end
    end
  end
end
