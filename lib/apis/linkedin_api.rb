require "nokogiri"
require 'oauth'
require 'json'

module Socnetapi
  class LinkedinApi
    def initialize(params = {})
      raise Socnetapi::Error::NotConnected unless params[:token]
      consumer = OAuth::Consumer.new params[:api_key], params[:api_secret], :site => "http://api.linkedin.com"
      @linkedin = OAuth::AccessToken.new(consumer, params[:token], params[:secret])
    end

    def get_entries options = {}
      res = @linkedin.get('/v1/people/~/network/updates', {'x-li-format' => 'json'})
      raise Socnetapi::Error::BadResponse.new(res.message, res.code, res.code) unless res.code == "200"
      values = JSON::parse(res.body)
      prepare_entries ((values.merge('values' => []) if values['_total'] == 0))
    end

    def create properties = {}
      res = @linkedin.put("/v1/people/~/current-status", "<?xml version=\"1.0\" encoding=\"UTF-8\"?><current-status>#{properties[:body]}</current-status>")
      raise Socnetapi::Error::BadResponse.new(res.message, res.code, res.code) unless res.code == "200"
      res
    end

    def update properties = {}
      delete
      create(properties)
    end

    def delete
      res = @linkedin.delete("/v1/people/~/current-status")
      raise Socnetapi::Error::BadResponse.new(res.message, res.code, res.code) unless res.code == "200"
      res
    end

    def friends
      res = @linkedin.get('/v1/people/~/connections', {'x-li-format' => 'json'})
      raise Socnetapi::Error::BadResponse.new(res.message, res.code, res.code) unless res.code == "200"
      values = JSON::parse(res.body)
      prepare_friends ((values.merge('values' => []) if values['_total'] == 0))
    end

    private

    def prepare_friends friends
      friends['values'].map do |friend|
        {
            id: friend['id'],
            name: "#{friend['firstName']} #{friend['lastName']}",
            userpic: friend['pictureUrl']
        }
      end
    end

    def prepare_entry entry
      return nil unless %w(CONN NCONN CCEM STAT JGRP JOBP PREC).include?(entry['updateType'])
      {
          id: entry['updateKey'],
          url: entry['updateContent']['person']['siteStandardProfileRequest']['url'],
          author: {
          id: entry['updateContent']['person']['id'],
          name: "#{entry['updateContent']['person']['firstName']} #{entry['updateContent']['person']['lastName']}",
          userpic: entry['updateContent']['person']['pictureUrl']
      },
          text: prepare_text(entry),
          created_at: Time.at(entry['timestamp'].to_i / 1000)
      }
    end

    def prepare_entries entries
      entries['values'].map do |entry|
        prepare_entry entry
      end.compact
    end

    def prepare_text entry
      case entry['updateType']
        when 'CONN'
          "<a href=\"#{entry['updateContent']['person']['siteStandardProfileRequest']['url']}\">#{entry['updateContent']['person']['firstName']} #{entry['updateContent']['person']['lastName']}</a> is now connected to " + entry['updateContent']['person']['connections']['values'].map do |conn|
            if conn.key?('siteStandardProfileRequest')
              "<a href=\"#{conn['siteStandardProfileRequest']['url']}\">#{conn['firstName']} #{conn['lastName']}</a>"
            else
              "private user"
            end
          end.join(', ')
        when 'NCONN'
          "<a href=\"#{entry['updateContent']['person']['siteStandardProfileRequest']['url']}\">#{entry['updateContent']['person']['firstName']} #{entry['updateContent']['person']['lastName']}</a> is now a connection."
        when 'CCEM'
          "<a href=\"#{entry['updateContent']['person']['siteStandardProfileRequest']['url']}\">#{entry['updateContent']['person']['firstName']} #{entry['updateContent']['person']['lastName']}</a> has joined LinkedIn."
        when 'STAT'
          entry['updateContent']['person']['currentStatus']
        when 'SHAR'
          puts entry
        when 'JGRP'
          "<a href=\"#{entry['updateContent']['person']['siteStandardProfileRequest']['url']}\">#{entry['updateContent']['person']['firstName']} #{entry['updateContent']['person']['lastName']}</a> joined the group " + entry['updateContent']['person']['memberGroups']['values'].map do |conn|
            "<a href=\"#{conn['siteGroupRequest']['url']}\">#{conn['name']}</a>"
          end.join(', ')
        when 'JOBP'
          "<a href=\"#{entry['updateContent']['job']['jobPoster']['siteStandardProfileRequest']['url']}\">#{entry['updateContent']['job']['jobPoster']['firstName']} #{entry['updateContent']['job']['jobPoster']['lastName']}</a> posted a job: #{entry['updateContent']['position']['title']} at #{entry['updateContent']['company']['name']}."
        when 'PREC'
          "<a href=\"#{entry['updateContent']['person']['siteStandardProfileRequest']['url']}\">#{entry['updateContent']['person']['firstName']} #{entry['updateContent']['person']['lastName']}</a> recommends " + entry['updateContent']['person']['recomendations-given']['values'].map do |conn|
            "<a href=\"#{conn['recommendee']['siteStandardProfileRequest']['url']}\">#{conn['recommendee']['firstName']} #{conn['recommendee']['lastName']}</a>: \"#{conn['recomendationSnippet']}\""
          end.join(', ')
      end
    end
  end
end
