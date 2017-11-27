require 'eventmachine'
require 'slack-ruby-client'

require './lib/main.rb'

TOKEN = ENV['SLACK_OBSERVER']

Slack.configure do |config|
  config.token = TOKEN
end

Slack::Web::Client.config do |config|
  config.user_agent = 'Slack Ruby Client/1.0'
end

client = Slack::RealTime::Client.new

client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}' to \
  the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
end

def cmd?(text)
  return false if text.nil? || text.empty?
  return false unless text.include?('hadl')
  true
end

def this_host?(text)
  return true unless ENV['HOSTNAME']
  text.include?(ENV['HOSTNAME'])
end

begin
  client.on :message do |data|
    text = data.text
    puts text
    case
    when cmd?(text) && text.include?('restart') && this_host?(text)
      start_point = text.scan(/\d/).join
      client.message channel: data.channel, text: "I restarted worker"
      Main.new.run!(start_point: start_point.to_i)
    end
  end

  client.on :close do |_data|
    puts 'Client is about to disconnect'
  end

  client.on :closed do |_data|
    puts 'Client has disconnected successfully!'
  end

  client.start!
rescue => e
  client.message channel: data.channel, text: "I've got the error. #{e.message} \n #{e.bactrace}"
end