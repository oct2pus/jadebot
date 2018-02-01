require 'redis'

module Bot
  module Commands
    module Settings
      extend Discordrb::Commands::CommandContainer
      command([:setting, :settings], description: "Allows Admins to set bot specific settings.\nusage: >settings `option` `selection`") do |event, *args|
        redis = Redis.new
        if args.empty? || args[0] == 'list'
          event << "warning: settings are currently quick and dirty, expect changes and breakages"
          event << "**here are the following options:**"
          event << "greeter\t(defaults: on)\t|\ton\t|\toff"
          event << "greeter_channel(defaults: 'general' or to first channel jadebot can send messages to)\t|\tany_channel (failed values will send it to the first channel jadebot can send messages to)"
        else
          case args[0]
            when 'greeter'
              if args[1].eql? 'off'
                redis.set "#{event.server.id}:GREETER", false
                event.send_message("greeter turned off")
              elsif args[1].eql? 'on'
                redis.set "#{event.server.id}:GREETER", true
                event.send_message("greeter turned on")
              else
                event.send_message("invalid selection, try `true` or `false`.")
              end
            when 'greeter_channel'
              if args.size > 1 && args[1].include?('<')
                greeter_channel =args[1].gsub(/[\D]|/, '')
                redis.set "#{event.server.id}:GREETER_CHANNEL", greeter_channel
                msg = args[1]
              elsif args.size > 1
                greeter_channel = event.server.text_channels.find { |c| c.name == args[1] }
                if greeter_channel.nil?
                  greeter_channel = event.server.default_channel
                end
                redis.set "#{event.server.id}:GREETER_CHANNEL", greeter_channel.id
                msg = greeter_channel.mention
              else
                redis.set "#{event.server.id}:GREETER_CHANNEL", event.server.default_channel.id
                msg = event.server.default_channel.mention
              end
              
              event.send_message("greeter channel set to #{msg}")
            else
              event.send_message("thats not a valid setting, do `setting list` for a list of settings!")
          end
        end
      end
    end
  end
end
