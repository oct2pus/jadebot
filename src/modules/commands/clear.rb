require 'redis'

module Bot
  module Commands
    # command mass deletes message on a discord channel
    module Clear
      extend Discordrb::Commands::CommandContainer
      command :clear do |event, amount = '10'|
        if event.user.permission?(:manage_messages) && Bot::JADE.profile.on(event.server).permission?(:manage_messages)
          if amount =~ /[0-9]/
            redis = Redis.new
            redis.set "#{event.server.id}:#{event.channel.id}:CLEAR", true
            event.channel.prune(amount.to_i)
            redis.del("#{event.server.id}:#{event.channel.id}:CLEAR")
            event.send_message("ive cleared #{amount} messages for you :P")
            if Bot::JADE.profile.on(event.channel.server).permission?(:manage_server) && Bot::JADE.profile.on(event.channel.server).permission?(:manage_channels)
              mod_log = event.server.text_channels.find { |c| c.name == 'mod-log' }
              mod_log = event.server.create_channel('mod-log') if mod_log.nil?
              if Bot::JADE.profile.on(event.server).permission?(:send_messages, mod_log)
                mod_log.send_embed do |embed|
                  embed.title = 'Clear'
                  embed.description = "**#{event.user.username}##{event.user.tag}** has deleted #{amount} messages\* in <##{event.channel.id}>."
                  embed.timestamp = Time.now
                  embed.color = 'FEFF1E'
                  embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: '*number of posts may be inaccurate due to a number of reasons. This is\'t rocket science.')
                  embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{event.user.username}##{event.user.tag}", icon_url: event.user.avatar_url.to_s)
                end
              end
            end
          end
        end
      end
    end
  end
end
