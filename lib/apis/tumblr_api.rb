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
    
    # @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
    # @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
    # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
    # @option options [Integer] :page Specifies the page of results to retrieve.
    def get_entries options = {}
      prepare_entries(JSON::parse(@tumblr.get("/v2/user/dashboard").body)["response"]["posts"])
    end
    
    def get_entry(id)
      prepare_entry(JSON::parse(@tumblr.get("/v2/blog/#{@blogname}/posts?id=#{id}&api_key=#{@api_key}").body)["response"]["posts"].last) rescue nil
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
      prepare_friends(JSON::parse(@tumblr.get("/v2/user/following").body)["response"]["blogs"])
    end
    
    private
    
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
      entries.map do |entry|
        prepare_entry entry
      end
    end

    def get_avatar blog_name
      JSON::parse(@tumblr.get("/v2/blog/#{blog_name.gsub(/http:\/\//,"")}/avatar/512").body)["response"]["avatar_url"]
    end

    def get_photos entry
      if entry["type"] == "photo"
        entry["photos"].map{|photo| photo["alt_sizes"].first["url"]}
      else
        return []
      end
    end

    def get_videos entry
      if entry["type"] == "video"
        {:embed_body => entry["player"].last["embed_code"] , :url => entry["source_url"] }
      else
        return []
      end
    end

    def get_audios entry
      if entry["type"] == "audio"
        {:embed_body => entry["player"] , :url => entry["source_url"] }
      else
        return []
      end

    end
    
  end
end
