require "vk_api"

module Socnetapi
  class VkontakteApi
    def initialize params = {}
      raise Socnetapi::Error::NotConnected unless params[:app_id] && params[:api_key]
      @vkontakte = ::VkApi::Session.new params[:app_id], params[:api_key]
    end
    
    def friends uid,access_token
    	prepare_friends(@vkontakte.friends.get(:uid => uid,:fields => "uid,first_name,last_name,nickname,photo",:access_token => access_token)) rescue []
    end
    
    def get_entries uid,access_token,count = 100 
			wall = @vkontakte.wall.get(:owner_id => uid,:access_token => access_token, :count => count)
			wall.shift
      prepare_entries wall rescue []
    end
    
    def get_entry uid,id,access_token
    	prepare_entry(@vkontakte.wall.getById(:posts => "#{uid}_#{id}",:access_token => access_token)[0])
    end
    
    def create access_token,params = {}
      res = @vkontakte.wall.post(:message => params[:message], :access_token => access_token)
      res["post_id"] if res
    end
    
    def delete id, access_token
      @vkontakte.wall.delete(:post_id => id, :access_token => access_token)
    end
    
    def update id,access_token, params = {}
      delete(id,access_token)
      res = @vkontakte.wall.post(:message => params[:message], :access_token => access_token)
      res["post_id"] if res
    end
   	
		def get_profile id
			profile = @vkontakte.getProfiles(:uids => id, :fields => 'fist_name,last_name,nickname,photo,photo_mediu,photo_big')
			prepare_profile(profile[0]["user"])
		end
    private
    
    def prepare_entry entry
      return unless (entry && entry.is_a?(Hash))
      {
        id: entry["id"],
        author: get_profile(entry["from_id"]), 
        title: entry["title"],
        text: entry["text"],
        attachments: entry["attachment"] ? {
					type: entry["attachment"]["type"],
					photo: entry["attachment"]["photo"] ? {
						id: entry["attachment"]["photo"]["pid"],
						src: entry["attachment"]["photo"]["src"],
						src_big: entry["attachment"]["photo"]["src_big"] 
					} : nil,
					posted_photo: entry["attachment"]["posted_photo"] ? {
						id: entry["attachment"]["posted_photo"]["pid"],
						src: entry["attachment"]["posted_photo"]["src"], 
						src_big: entry["attachment"]["posted_photo"]["src_big"] 
					} : nil,
					graffiti: entry["attachment"]["graffity"] ? {
						id: entry["attachment"]["graffity"]["pid"],
						src: entry["attachment"]["graffity"]["src"],
						src_big: entry["attachment"]["graffity"]["src_big"] 
					} : nil,
					audio: entry["attachment"]["audio"] ? {
						id: entry["attachment"]["audio"]["aid"],
						title: entry["attachment"]["audio"]["title"], 
						performer: entry["attachment"]["audio"]["performer"] 
					} : nil,
					doc: entry["attachment"]["doc"] ? { 
						id: entry["attachment"]["doc"]["did"],
						title: entry["attachment"]["doc"]["title"], 
						size: entry["attachment"]["doc"]["size"], 
						ext: entry["attachment"]["doc"]["ext"] 
					} : nil,
					link: entry["attachment"]["link"] ? {
						url: entry["attachment"]["link"]["url"],
						title: entry["attachment"]["link"]["title"],
						description: entry["attachment"]["link"]["description"]
					} : nil,
					note: entry["attachment"]["note"] ? {
						id: entry["attachment"]["note"]["nid"],
						title: entry["attachment"]["note"]["title"]
					} : nil,
					app: entry["attachment"]["app"] ? {
						id: entry["attachment"]["app"]["app_id"],
						name: entry["attachment"]["app"]["app_name"],
						src: entry["attachment"]["app"]["src"],
						src_big: entry["attachment"]["app"]["src_big"]
					} : nil,
					poll: entry["attachment"]["poll"] ? {
						id: entry["attachment"]["poll"]["poll_id"],
						question: entry["attachment"]["poll"]["question"]
					} : nil,

        } : nil,
        created_at: entry["date"]
      }
    end
    
    def prepare_entries entries
      entries.map do |entry|
       	prepare_entry(entry)
      end
    end
    
    def prepare_friends friends
      friends.map do |friend|
				 prepare_profile friend
			end
    end

		def prepare_profile profile
			return unless profile.is_a?(Hash)
			{
    		id: profile["uid"],
        first_name: profile["first_name"],
        last_name: profile["last_name"],
        nickname: profile["nickname"],
        photo: profile["photo"],
        photo_medium: profile["photo_medium"],
        photo_big: profile["photo_big"]
      }
		end
  end
end
