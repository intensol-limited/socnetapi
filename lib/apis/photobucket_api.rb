module Socnetapi
  class PhotobucketApi
    def initialize params = {}
      raise Socnetapi::Error::NotConnected unless params[:token]
      consumer = OAuth::Consumer.new(params[:api_key], params[:api_secret],
        {
            :site => "http://api971.photobucket.com",
            :scheme => :header,
            :request_token_path => '/login/request',
            :authorize_path => '/apilogin/login',
            :access_token_path => '/login/access'
        })
      @pb = OAuth::AccessToken.new(consumer, params[:token], params[:secret])
    end
    
    def connection
      @pb
    end
    
    def friends
      prepare_friends()
      rescue exception_block
    end
    
    def get_entries
      prepare_entries()
    rescue exception_block
    end
    
    def get_entry id
      prepare_entry()
    rescue exception_block
    end
    
    def create params = {}
      # res["id"]
    rescue exception_block
    end
    
    def delete id
    rescue exception_block
    end
    
    def update id, params = {}
      # res["id"]
    rescue exception_block
    end
    
    private
    
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

    def exception_block
      #(raise ($!.code == 401) ? Socnetapi::Error::Unauthorized : $!) if $!
      raise $! if $!
    end
  end
end


