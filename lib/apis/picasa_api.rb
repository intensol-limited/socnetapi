require 'gdata'

module Socnetapi
  class PicasaApi
    def initialize params
      raise Socnetapi::Error::NotConnected unless params[:token]
      @picasa = GData::Client::Photos.new
    end
  end
end
