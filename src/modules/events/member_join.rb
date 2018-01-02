require 'redis'

module Bot
  module Events
    # event logs every time a user joins as well as publically annouces it
    module MemberJoin
      extend Discordrb::EventContainer
      member_join do |event|
        if Bot::JADE.profile.on(event.server).permission?(:use_voice_activity)
          default_channel = event.server.default_channel
          if default_channel.nil?
            default_channel = event.server.text_channels.find { |c| c.name == 'general' }
          end
          # event.server.default_channel.send_embed("hello! :D") do |embed|
          default_channel.send_embed('hello! :D') do |embed|
            embed.timestamp = Time.now

            embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: event.user.avatar_url)
            embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Member Count: #{event.server.member_count}")
            embed.add_field(name: 'a new user appears! :D', value: "welcome to the server,\n**#{event.user.username}##{event.user.tag}**!")
          end
        end
        if Bot::JADE.profile.on(event.server).permission?(:manage_server) && Bot::JADE.profile.on(event.server).permission?(:manage_channels)
          redis = Redis.new

          redis.set "#{event.server.id}:#{event.user.id}", event.user.display_name.to_s

          redis.close

          mod_log = event.server.text_channels.find { |c| c.name == 'mod-log' }
          mod_log = event.server.create_channel('mod-log') if mod_log.nil?

          if Bot::JADE.profile.on(event.server).permission?(:send_messages, mod_log)
            mod_log.send_embed do |embed|
              embed.title = 'A User Joined The Server'
              embed.description = "**#{event.user.username}##{event.user.tag}** has joined **#{event.server.name}**"
              embed.timestamp = Time.now
              embed.color = '#21AA21'
              embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Member Count: #{event.server.member_count}")
              embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{event.user.username}##{event.user.tag}", icon_url: event.user.avatar_url.to_s)
            end
          end
        end
      end
    end
  end
end
