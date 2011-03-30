require "koala"

module Socnetapi
  class FacebookApi
    def initialize data = {}
      data[:token] ||= "125273294164789|08fc1959b4b4822a1f0754bd-100002277932808|s_xsLh35VaKt5EmysYBYS3FLSMc"
      data[:api_key] ||= 'af2a48ca59c1ca00f6f7b3d0b7490082'
      data[:api_secret] ||= '8d7250d31035e81ed487ada9d63d5793'
      @facebook = Koala::Facebook::GraphAPI.new(data[:token])
    end
    
    def friends
      prepare_friends(@facebook.get_connections("me", "friends")) rescue []
    end
    
    def entries
      prepare_entries(@facebook.get_connections("me", "home")) rescue []
    end
    
    def entry id
      prepare_entry(@facebook.get_object(id))
    end
    
    def create params = {}
      res = @facebook.put_wall_post(params[:body])
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
          name: entry["from"]["name"]
        },
        title: entry["name"],
        text: entry["message"],
        attachments: {
          images: entry["picture"] ? [entry["picture"]] : []
        },
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
          name: friend["name"]
        }
      end
    end
  end
end