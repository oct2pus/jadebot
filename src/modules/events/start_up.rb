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
          check.default_channel.send_message("i now have a >setting command, you can use it to disable the new user greeter/leaver and select what channel i send the message to, because of how discord has changed how default channels are handled I will instead send messages to the first channel i have send message permissions on, I recommend changing this to your prefered channel with ``>settings greeter_channel`. i apologize for the intrusion and i hope you have a lovely day!")
          puts "sent message to #{check.name}, sleeping for 60 seconds"
          sleep(60)
        end
      end
    end
  end
end
