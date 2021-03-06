require "vk_api"

module Socnetapi
  class VkontakteApi
    def initialize params = {}
      raise Socnetapi::Error::NotConnected unless params[:app_id] && params[:api_key]
      @vkontakte = ::VkApi::Session.new params[:app_id], params[:api_key]
            @uid = params[:uid]
            @access_token = params[:access_token]
    end

    def friends
      prepare_friends(@vkontakte.friends.get(:uid => @uid, :fields => "uid,first_name,last_name,nickname,photo", :access_token => @access_token))
    rescue exception_block
    end

    def news
      @news
    end

    def get_entries count = 100
      #грузит только новости друзей
      #@source_ids=[]
      #friends.each do |friend|
      #  @source_ids << friend[:id]
      #end
      #news = @vkontakte.newsfeed.get(:access_token => @access_token, :count => count, :source_ids => @source_ids.to_s)
      #грузит новости и от групп
      @news = @vkontakte.newsfeed.get(:access_token => @access_token, :count => count)
      prepare_entries(news["items"]).compact
    rescue exception_block
    end

    def get_entry id
      prepare_entry(@vkontakte.wall.getById(:posts => "#{@uid}_#{id}",:access_token => @access_token)[0])
    rescue exception_block
    end

    def create params = {}
      res = @vkontakte.wall.post(:message => params[:message], :access_token => @access_token)
      res["post_id"] if res
    rescue exception_block
    end

    def delete id
      @vkontakte.wall.delete(:post_id => id, :access_token => @access_token)
    rescue exception_block
    end

    def update id, params = {}
      delete(id)
      res = @vkontakte.wall.post(:message => params[:message], :access_token => @access_token)
      res["post_id"] if res
    rescue exception_block
    end

    def get_profile id
      if id > 0
        sleep(0.35)
        profile = @vkontakte.getProfiles(:uids => id, :fields => 'fist_name,last_name,nickname,photo,photo_medium,photo_big', :access_token => @access_token)
        prepare_profile(profile[0])
      else
        #айдишник группы при поступлении меньше нуля
        #profile = @vkontakte.groups.getById(:gid => id.abs, :access_token => @access_token)
        prepare_group(news['groups'].select {|v| v['gid'] == id.abs}.first)
      end
    rescue exception_block
    end

    def get_video owner_id, id
      video = @vkontakte.video.get(:videos => "#{owner_id}_#{id}", :access_token => @access_token)
      video.shift
      prepare_video(video[0])
    rescue exception_block
    end

    private

    def prepare_entry entry
      return unless entry.is_a?(Hash)
      {
        id: entry["post_id"],
        author: entry["source_id"] ? get_profile(entry["source_id"]) : get_profile(entry["from_id"]),
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
          video: entry["attachment"]["video"] ? get_video(entry["attachment"]["video"]["owner_id"],entry["attachment"]["video"]["vid"]) : nil,
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
        images: entry["photos"] ? prepare_photos(entry["photos"]) : nil,
        created_at: Time.at(entry["date"])
      } unless entry["type"] == "friend"
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
          name: "#{profile["first_name"]} #{profile["last_name"]}",
          nickname: profile["nickname"],
          userpic: profile["photo"]
      }
    end

    def prepare_group group
      return unless group.is_a?(Hash)
      {
          id: group["gid"],
          name: group["name"],
          userpic: group["photo"]
      }
    end

    def prepare_video video
      return unless video.is_a?(Hash)
      {
          id: video["vid"],
          title: video["title"],
          description: video["description"],
          url: video["player"]
      }
    end

    def prepare_photos photos
      urls = []
      photos.shift
      photos.each { |photo| photo.is_a?(Hash) ? urls << photo["src_big"] : nil }
      urls
    end

    def exception_block
      #(raise ($!.response.status_code == 401) ? Socnetapi::Error::Unauthorized : $!) if $!
      raise $! if $!
    end
  end
end
