# encoding=utf-8
require 'irb'
require 'bundler/setup'
require 'gdata'
require 'socnetapi'

config = YAML::load_file('spec/config.yml')

@picasa = Socnetapi::PicasaApi.new config['picasa']
@youtube = Socnetapi::YoutubeApi.new config['youtube']
@fr = Socnetapi::FriendsterApi.new config['friendster']

IRB.start