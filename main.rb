require 'twitter'
require 'pp'
require 'json'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TW_CONSUMER_KEY']
  config.consumer_secret     = ENV['TW_CONSUMER_SECRET']
  config.access_token        = ENV['TW_ACCESS_TOKEN']
  config.access_token_secret = ENV['TW_ACCESS_SECRET']
end

mentions = client.mentions_timeline(count: 100)

mention_users = mentions.inject([]) do |data, mention|
  d = {}
  d[:id] = mention.attrs[:user][:id]
  d[:name] = mention.attrs[:user][:name]
  d[:full_text] = mention.full_text
  d[:screen_name] = mention.attrs[:user][:screen_name]
  data << d
end

following_ids = client.friend_ids.attrs[:ids]
no_interest_users = mention_users.map{ |u| u[:id] } - following_ids

pp client.block(no_interest_users)

File.open("/tmp/tw_blocked", "a") do |f|
  f.write(mention_users.select{ |u| no_interest_users.include?(u[:id]) }.to_json + "\n")
end
