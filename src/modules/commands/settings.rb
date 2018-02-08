module Bot
  module Commands
    module Settings
      extend Discordrb::Commands::CommandContainer
      command(%i[setting settings], description: "Allows Admins to set bot specific settings.\nusage: >settings `option` `selection`") do |event, *args|
        if event.user.permission?(:administrator)
          server_settings = JSON.parse($Redis.get("#{event.server.id}:SETTINGS"))
          if args.empty?
            event.channel.send_embed() do |embed|
              embed.title = "Current Options:"
              server_settings.each do |name, value|
                embed.add_field(name: name, value: "`#{value}`")
              end
            end
          else
            bad_choice = "thats not a valid setting!\ntry"
            case args[0]
              #list
            when 'list', 'options', 'defaults', 'default'
              # $Options is defined in src/modules/guild_settings.rb
              event.channel.send_embed() do |embed|
                embed.title = "Available Options:"
                $Options.each do |name, attributes|
                  embed.add_field(name: name, value: "description: #{attributes[:description]}\ndefault: `#{attributes[:default]}`")
                end
              end
               # greeting_channel
            when 'greeter_channel', 'greeting_channel'

              if args.size > 1 && args[1].include?('<')
                greeter_channel = args[1].gsub(/[\D]|/, '')
                server_settings['greeting_channel'] = greeter_channel

              elsif args.size > 1
                greeter_channel = event.server.text_channels.find { |c| c.name == args[1] }

                if greeter_channel.nil?
                  server_settings['greeting_channel'] = event.server.default_channel.id

                end

                server_settings['greeting_channel'] = greeter_channel.id
              else
                server_settings['greeting_channel'] = event.server.default_channel.id
              end

              event.send_message("greeter channel set to <\##{server_settings['greeting_channel']}>")
              # greet
            when 'greeter', 'greet'

              if args[1].eql? 'off'
                server_settings['greet'] = false
                event.send_message('chat greeter turned off! D:')
              elsif args[1].eql? 'on'
                server_settings['greet'] = true
                event.send_message('chat greeter turned on! :D')

                if server_settings['greeting_channel'].nil?
                  server_settings['greeting_channel'] = event.server.default_channel.id
                end
              else
                event.send_message("#{bad_choice} `on` or `off`.")
              end
              # interaction
            when 'interaction', 'message', 'messages', 'verbosity'

              if args[1] == 'none'
                server_settings['interaction'] = 0
                event.send_message('ill keep quite then :(')
              elsif args[1] == 'nowaifu'
                server_settings['interaction'] = 1
                event.send_message('ill keep it toned down :v')
              elsif args[1] == 'all'
                server_settings['interaction'] = 2
                event.send_message('ill make sure to speak my mind :P')
              else
                event.send_message("#{bad_choice} `none`, `nowaifu`, `all`")
              end
            when 'mspa', 'search', 'blocklist', 'block'

              blocklist = server_settings['mspa']

              if args[1] == 'block' && args.length > 2

                args.shift(2) # this removes 'mspa' and 'block/unblock' from
                # args array, kept inside if statement for
                # simplicity

                # this could be simplified to one long command but its much
                # more readable this way
                blocklist = blocklist.concat(args)
                server_settings['mspa'] = blocklist.sort.uniq
                event.send_message("the `>mspa` command will now block\n`#{server_settings['mspa'].join(' ')}`")

              elsif args[1] == 'unblock' && args.length > 2

                args.shift(2)

                blocklist -= args
                server_settings['mspa'] = blocklist.sort.uniq
                event.send_message("the mspa command will now block\n`#{server_settings['mspa'].join(' ')}`")

              elsif args[1] == 'reset'
                server_settings['mspa'] = $Options[:mspa][:default]
                event.send_message("the mspa command will now block\n`#{server_settings['mspa'].join(' ')}`")
              else
                event.send_message("#{bad_choice} `>setting mspa block`, `>setting mspa unblock`, or `>setting mspa reset`")
              end
              # greeter_message
            when 'greeter_message', 'greet_message'
              args.shift
              server_settings['greeter_message'] = args.join(' ')
              event.send_message("greeter message set to `#{server_settings['greeter_message']}`")
              # leaver_message
            when 'leaver_message', 'leave_message'
              args.shift
              server_settings['leaver_message'] = args.join(' ')
              event.send_message("leaver message set to `#{server_settings['leaver_message']}`")
            else
              event.send_message("#{bad_choice} `>setting list` for a list of settings!")
            end # end case
            puts "updated settings on #{event.server.name}: #{server_settings}"
            $Redis.set "#{event.server.id}:SETTINGS", server_settings.to_json

          end
          nil
        else
          event.send_temporary_message('you must be an administrator to use this command :P', 5)
        end
      end
    end
  end
end
