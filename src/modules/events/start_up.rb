require 'redis'
require 'json'

module Bot
  module Events
    # commands to run when bot starts running
    module StartUp
      extend Discordrb::EventContainer
      ready do |_event|
        redis = Redis.new
        puts "===Total Number of Servers: #{Bot::JADE.servers.size}==="
        puts 'Server default settings:'
        Bot::JADE.servers.each_value do |server|
#          redis.del "#{server.id}:SETTINGS" # for when needed
          unless redis.exists "#{server.id}:SETTINGS"
            hash = GuildSettings.new.to_h
            puts "Server settings non-existant for #{server.name}, creating..."
            redis.set "#{server.id}:SETTINGS", hash.to_json
          end
          # keep this for now
          puts "#{server.name}: #{JSON.parse(redis.get("#{server.id}:SETTINGS"))}"
        end
        puts '===Jadebot initalized!==='
        redis.close
      end
    end
  end
end
