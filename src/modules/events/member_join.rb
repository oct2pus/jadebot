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
      end
    end
  end
end
