require 'xmlrpc/client'

module Socnetapi
  class WordpressApi
    def initialize params = {}
      @login = params[:login]
      @password = params[:password]
      @blog_url = params[:blog_url]
      @wordpress = XMLRPC::Client.new2("#{@blog_url}/xmlrpc.php")
    end
        
    def client
      @wordpress
    end
    
    def delete(id)
      @wordpress.call('metaWeblog.deletePost', 0, id, @login, @password,  true)
    end


    def update(id, params = {})
      post = { 'title'  => params[:title], 'description' => params[:body]}
      @wordpress.call('metaWeblog.editPost', id, @login, @password, post,  true)
    end

    def create(params = {})
      post = { 'title'  => params[:title], 'description' => params[:body]}
      @wordpress.call('metaWeblog.newPost', 0, @login, @password, post,  true).to_i
    end

  end

end
