require 'gdata'

module Socnetapi
  class YoutubeApi
    def initialize params = {}
      params[:developer_key] ||= 'AI39si4vwXwDLR5MrtsdR1ULUD8__EnEccla-0bnqV40KpeFDIyCwEv0VJqZKHUsO3MvVM_bXHp3cAr55HmMYMhqfxzLMUgDXA'
      params[:login] || = "intensoldev"
      params[:token] ||= "1/H6KqiAht4m7B7OMvYKnSrkcsTF_0VRUCzbOHzSFSEKY"
      
      @youtube = GData::Client::YouTube.new
      @youtube.developer_key = params[:developer_key]

      @youtube.authsub_token = params[:token]
      @youtube.client_id = params[:login]
      @youtube
    end
  end
end