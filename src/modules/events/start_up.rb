require 'redis'

module Bot
  module Events
    # commands to run when bot starts running
    module StartUp
      extend Discordrb::EventContainer
      ready do |_event|
        redis = Redis.new
        puts "Total Number of Servers: #{Bot::JADE.servers.size}"
        puts 'Jadebot initalized!'
        Bot::JADE.servers.values.each do |check|
          puts "adding settings to #{check.name}"
          redis.set "#{check.id}:GREETER", true
          redis.set "#{check.id}:GREETER_CHANNEL", check.default_channel.id
          puts "sent message to #{check.name}, sleeping for 60 seconds"
        end
      end
    end
  end
end
