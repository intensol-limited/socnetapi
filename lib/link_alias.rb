require 'googl'

module Socnetapi
  def self.included(klass)
    klass.extend ClassMethods
  end
  module ClassMethods
    #def initialize api, secret, redirect_url
    #  @client = Googl::OAuth2.server(api, secret, redirect_url)
    #  @client.authorize_url
    #end

    #def finish_initialize code
    #  client.request_access_token(code)
    #  client.authorized?
    #end

    def initialize_client google_mail, google_password
      @client = Googl.client(google_mail, google_password)
    end

    def to_short(url)
      url = @client.shorten(url)
      url.short_url
    end

    def to_long(url)
      url = @client.expand(url)
      url.long_url
    end
  end
end

