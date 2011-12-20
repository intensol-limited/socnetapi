require 'vimeo'
require 'date'

module Socnetapi
  class VimeoApi
    def initialize params = {}
      raise Socnetapi::Error::NotConnected unless params[:token]
      @api_key, @api_secret, @token_hash = params[:api_key], params[:api_secret], {:token => params[:token], :secret => params[:secret]}
      @user_id = params[:user_id]
    end
    
    def friends
      vimeo_contacts = Vimeo::Advanced::Contact.new(@api_key, @api_secret, @token_hash)
      prepare_friends vimeo_contacts.get_all(@user_id) rescue []
    end
    
    def get_entries
      prepare_entries Vimeo::Simple::Activity.contacts_did(@user_id)
    end
    
    def get_entry id
      vimeo_video = Vimeo::Advanced::Video.new(@api_key, @api_secret, @token_hash)
      prepare_entry vimeo_video.get_info(id)
    end
    
    # params: title, description, tags, file_path 
    def create(file_path, params = {})
      return unless file_path
      upload = Vimeo::Advanced::Upload.new(@api_key, @api_secret, @token_hash)

      upload.get_quota
      ticket = upload.get_ticket
      puts ticket.inspect
      puts "ticket---------------"
      return unless ticket["stat"]=="ok" 
      ticket_id = ticket["ticket"]["id"]
      end_point = ticket["ticket"]["endpoint"]

      upload_res = upload.upload(file_path, ticket_id, end_point)
      puts JSON.parse(upload_res).inspect
      puts "upload_res----------"
      # manifest = upload.verify_manifest(ticket_id, upload_res)
      # puts manifest.inspect
      puts "manifest----------------"
      confirm = upload.confirm(ticket_id)
      puts confirm.inspect
      puts "confirm------------"
      video_id = confirm["ticket"]["video_id"]
      vimeo_video = Vimeo::Advanced::Video.new(@api_key, @api_secret, @token_hash)
      vimeo_video.set_description(video_id, params[:description]) if params[:description]
      vimeo_video.set_title(video_id, params[:title]) if params[:title]
      vimeo_video.add_tags(video_id, params[:tags]) if params[:tags]
      video_id
    end

    # params: title, description, tags, id
    def update(id, params = {})
      begin
        vimeo_video = Vimeo::Advanced::Video.new(@api_key, @api_secret, @token_hash)

        return unless id
        puts "Vimeo: Updating #{id}"

        vimeo_video.set_description(id, params[:description]) if params[:description]
        vimeo_video.set_title(id, params[:title]) if params[:title]
        vimeo_video.clear_tags(id) if params[:tags]
        vimeo_video.add_tags(id, params[:tags]) if params[:tags]
      rescue
        puts "Vimeo: Updating #{id} failed!"
      end
    end

    def delete(id)
      return unless id
      begin
        vimeo_video = Vimeo::Advanced::Video.new(@api_key, @api_secret, @token_hash)
        puts "Vimeo: Deleting #{video_id}"
        vimeo_video.delete(id) if id
      rescue
        puts "Vimeo: Deleting #{video_id} failed!"
      end
    end
    
    private
    
    def prepare_entry entry
      video = entry["video"][0]
      {
        id: video["id"],
        created_at: DateTime.strptime(video["modified_date"],'%Y-%m-%d %T').to_s,
        title: video["title"],
        description: video["description"],
        tags: video["tags"]["tag"].map{|tag| tag["_content"]},
        author: {
          id: video["owner"]["id"],
          name: video["owner"]["realname"],
          nickname: video["owner"]["username"],
          userpic: video["owner"]["portraits"]["portrait"][1]["_content"]
        },
        thumb: video["thumbnails"]["thumbnail"][1]["_content"],
        url: video["urls"]["url"][0]["_content"]
      }
    end
    
    def prepare_entries entries
      entries.map do |entry|
        if (entry.is_a?(Array))
          {
              error: entry[1].inspect
          }
        else
          if entry["type"] == "upload"
            {
              id: entry["video_id"],
              created_at: DateTime.strptime(entry["date"],'%Y-%m-%d %T').to_s,
              title: entry["video_title"],
              description: entry["video_description"],
              author: {
                id: entry["subject_id"],
                name: entry["subject_name"],
                userpic: entry["subject_portrait_medium"]
              },
              thumb: entry["video_thumbnail_small"],
              url: entry["video_url"]
            }
          end
        end
      end
    end
    
    def prepare_friends friends
      friends["contacts"]["contact"].map do |friend|
        {
          id: friend["id"],
          nickname:  friend["display_name"],
          name: friend["realname"],
          userpic: friend["portraits"]["portrait"][1]["_content"]
        }
      end
    end
  end
end
