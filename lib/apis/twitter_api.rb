require "nokogiri"
require "twitter"

module Socnetapi
  class TwitterApi
    def initialize(params = {})
      raise Socnetapi::Error::NotConnected unless params[:token]
      
      oauth = ::Twitter::OAuth.new(params[:api_key], params[:api_secret])
      oauth.authorize_from_access(params[:token], params[:secret])
      @twitter = Twitter::Base.new(oauth)
    end
    
    # @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
    # @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
    # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
    # @option options [Integer] :page Specifies the page of results to retrieve.
    def get_entries options = {}
      prepare_entries @twitter.home_timeline(options)
    end
    
    def get_entry id
      prepare_entry(@twitter.status(id)) rescue nil
    end
    
    def create properties = {}
      res = @twitter.update(properties[:body])
      res.id rescue nil
    end
    
    def update id, properties = {}
      delete(id)
      create(properties)
    end
    
    def delete id
      @twitter.status_destroy(id)
    end
    
    def friends
      prepare_friends @twitter.friends
    end
    
    private
    
    def prepare_friends friends
      friends.map do |friend|
        {
          id: friend[:id],
          name: friend[:name],
          userpic: friend[:profile_image_url],
          nickname: friend[:screen_name]
        }
      end
    end
    
    def prepare_entry entry
      {
        id: entry[:id],
        author: {
          id: entry[:user][:id],
          name: entry[:user][:name],
          userpic: entry[:user][:profile_image_url],
          nickname: entry[:user][:screen_name]
        },
        text: entry[:text],
        created_at: entry[:created_at]
      }
    end
    
    def prepare_entries entries
      entries.map do |entry|
        prepare_entry entry
      end
    end
    
  end
end