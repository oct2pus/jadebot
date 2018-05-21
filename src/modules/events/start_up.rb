# frozen_string_literal: true

module Bot
  module Events
    # commands to run when bot starts running
    module StartUp
      extend Discordrb::EventContainer
      ready do |_event|
        puts "===Total Number of Servers: #{Bot::JADE.servers.size}==="
        puts "===Shard ID: #{Bot::JADE.shard_key[0]}==="
        puts "===Number of Shards: #{Bot::JADE.shard_key[1]}==="
        # puts 'Server default settings:'
        Bot::JADE.servers.each_value do |server|
          # Re::DIS.del "#{server.id}:SETTINGS" # for when needed
          next if Re::DIS.exists "#{server.id}:SETTINGS"
          hash = GuildSettings.new.to_h
          puts "Server settings non-existant for #{server.name}, creating..."
          Re::DIS.set "#{server.id}:SETTINGS", hash.to_json
          # debug feature
          # puts "#{server.name}: #{JSON.parse(Re::DIS.get("#{server.id}:SETTINGS"))}"
        end
        puts '===Jadebot initalized!==='
      end
    end
  end
end
