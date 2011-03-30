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
      @facebook.get_connections("me", "friends")
    end
    
    def entries
      @facebook.get_connections("me", "home")
    end
    
    def entry id
      @facebook.get_object(id) || nil
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
  end
end