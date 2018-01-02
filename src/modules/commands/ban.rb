require 'redis'

module Bot
  module Commands
    # command kicks a user from the server, requires user to have "kick members" permission
    module Ban
      extend Discordrb::Commands::CommandContainer
      command :ban do |event, *args|
        if event.user.permission?(:ban_members) && Bot::JADE.profile.on(event.server).permission?(:ban_members)
          redis = Redis.new
          if Bot::JADE.parse_mention(args[0])
            user_target = Bot::JADE.parse_mention(args[0])
            event.send_message("**#{user_target.username}##{user_target.tag}** has been banned from the server :p")

            if Bot::JADE.profile.on(event.server).permission?(:manage_channels) && Bot::JADE.profile.on(event.server).permission?(:manage_server)
              mod_log = event.server.text_channels.find { |c| c.name == 'mod-log' }
              mod_log = event.server.create_channel('mod-log') if mod_log.nil?

              if Bot::JADE.profile.on(event.server).permission?(:send_messages, mod_log)
                reason = ''

                redis.set "#{event.server.id}:#{user_target.id}:BANKICK", true

                if args.size > 1
                  args[1..(args.size - 1)].each { |word| reason += "#{word} " }
                else
                  reason = 'No reason given.'
                end

                mod_log.send_embed do |embed|
                  embed.title = 'Ban'
                  embed.description = "#{event.user.username}##{event.user.tag} has banned #{user_target.username}##{user_target.tag}"
                  embed.timestamp = Time.now
                  embed.color = '88AOBD'
                  embed.add_field(name: 'Reason', value: reason.to_s)
                  embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Member Count: #{event.server.member_count - 1}")
                  embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{event.user.username}##{event.user.tag}", icon_url: event.user.avatar_url.to_s)
                end
              end
            end
          end

          redis.close

          event.server.ban(user_target)
        else
          event.send_message('please **mention** a valid user')
        end
      end
    end
  end
end
