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
              mod_log = server.text_channels.find { |c| c.name == 'mod-log' }
              mod_log = server.create_channel('mod-log') if mod_log.nil?

              mod_log.send_message("@everyone heyo, im removing jadebot's moderation features in 48 hours because of a desire to focus on what make jadebot unique(being cute and commands useful for homestuck servers), I have a new moderation bot here you can use or you can swap to someone else's solution, I won't be mad, I promise. Please invite https://discordapp.com/oauth2/authorize?client_id=404624723595493378&scope=bot&permissions=268790838 to continue using 'jadebot's mod-log.")
            server.members.each do |member|
              redis.set "#{server.id}:#{member.id}", member.display_name.to_s
            end
            sleep(20)
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
