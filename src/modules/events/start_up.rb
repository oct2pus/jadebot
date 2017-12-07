require 'redis'

module Bot
  module Events
    # commands to run when bot starts running
    module StartUp
      extend Discordrb::EventContainer
      ready do |_event|
        redis = Redis.new
        counter = 0

        puts "Total Number of Servers: #{Bot::JADE.servers.size}"

        Bot::JADE.servers.each do |_dummy, server|
          counter += 1
          puts "#{counter}: #{server.name} started loading users."
          if Bot::JADE.profile.on(server).permission?(:manage_server) && Bot::JADE.profile.on(server).permission?(:manage_channels)
            server.members.each do |member|
              redis.set "#{server.id}:#{member.id}", member.display_name.to_s
            end
          else
            puts "#{counter}: #{server.name} does not have :manage_server and/or :manage_channels permissions, skipping."
          end

          puts "#{counter}: #{server.name} finished loading users."
        end

        if counter != Bot::JADE.servers.size
          puts 'Error: failed to load all servers'
        else
          puts 'Success: loaded all servers.'
        end

        Bot::JADE.game = "Running on #{Bot::JADE.servers.size} servers."

        redis.close
      end
    end
  end
end
