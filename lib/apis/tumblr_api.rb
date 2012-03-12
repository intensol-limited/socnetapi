require "nokogiri"
require 'json'

module Socnetapi
  class TumblrApi
    def initialize(params = {})
      raise Socnetapi::Error::NotConnected unless params[:token]
      @api_key = params[:api_key]
      @blogname = params[:blogname]
      consumer = OAuth::Consumer.new params[:api_key],  params[:api_secret],  :site => "http://api.tumblr.com"
      @tumblr = OAuth::AccessToken.new(consumer, params[:token], params[:secret])
    end

    def user_blogs
      @user_blogs ||= get_user_blogs || []
    end

    def user_avatar
      @user_avatar ||= get_user_avatar || ""
    end

    # @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
    # @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
    # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
    # @option options [Integer] :page Specifies the page of results to retrieve.
    def get_entries options = {}
      prepare_entries(JSON::parse(@tumblr.get("/v2/user/dashboard").body)["response"]["posts"])
    end

    def get_user_avatar
      JSON::parse(@tumblr.get("/v2/blog/#{user_blogs.first}.tumblr.com/avatar").body)["response"]["avatar_url"]
    end

    def get_user_blogs
      prepare_user_blogs(JSON::parse(@tumblr.post("/v2/user/info").body)['response']['user']['blogs'])
    end
    
    def get_entry(id)
      prepare_entry(JSON::parse(@tumblr.get("/v2/blog/#{@blogname}/posts?id=#{id}&api_key=#{@api_key}").body)["response"]["posts"].last)
    end

    def create properties = {}
      res = JSON::parse(@tumblr.post("/v2/blog/#{@blogname}/post",properties).body)["response"]["id"]
      return nil unless res
      res
    end
    
    def update properties = {}
      @tumblr.post("/v2/blog/#{@blogname}/post/edit",properties)
    end
    
    def delete(id)
      @tumblr.post("/v2/blog/#{@blogname}/post/delete",{:id => id})
    end
    
    def friends
      js = JSON::parse(@tumblr.get("/v2/user/following").body)
      raise Socnetapi::Error::BadResponse if js["meta"]["status"] != 200
      prepare_friends(js["response"]["blogs"])
    end
    
    private

    def prepare_user_blogs blogs
      blogs.map { |v| v['name'] }
    end

    def prepare_friends friends
      friends.map do |friend|
        {
          id: friend["name"],
          name: friend["name"],
          userpic: get_avatar(friend["url"])
        }
      end
    end
    
    def prepare_entry entry
      {
        id: entry["id"],
        url: entry["post_url"],
        author: {
          id: entry["blog_name"],
          name: entry["blog_name"],
          userpic: get_avatar("#{entry["blog_name"]}.tumblr.com"),
        },
        title: entry["title"] || entry["question"] || entry["source_title"] ||"",
        attachments: {
          :images => get_photos(entry),
          :videos => get_videos(entry),
          :audios => get_audios(entry)
        },
        text: entry["body"] || entry["caption"] || entry["text"] || entry["answer"] || entry["description"] || "",
        created_at: Time.at(entry["timestamp"])
      }
    end
    
    def prepare_entries entries
      entries.map { |entry| prepare_entry entry }
    end

    def get_avatar blog_name
      JSON::parse(@tumblr.get("/v2/blog/#{blog_name.gsub(/http:\/\//,"")}/avatar/512").body)["response"]["avatar_url"]
    end

    def get_photos entry
      entry["type"] == "photo" ? entry["photos"].map{|photo| photo["alt_sizes"].first["url"]} : []
    end

    def get_videos entry
      entry["type"] == "video" ? {:embed_body => entry["player"].last["embed_code"] , :url => entry["source_url"] } : []
    end

    def get_audios entry
      entry["type"] == "audio" ? {:embed_body => entry["player"] , :url => entry["source_url"] } : []
    end
  end
end
