module Bot
  module Events
    # event logs every time a user leaves as well as publically annouces it
    module MemberLeave
      extend Discordrb::EventContainer
      member_leave do |event|
        if Bot::JADE.profile.on(event.server).permission?(:use_voice_activity)
          default_channel = event.server.default_channel
          if default_channel.nil?
            default_channel = event.server.text_channels.find { |c| c.name == 'general' }
          end
          # event.server.default_channel.send_embed("goodbye! D:") do |embed|
          default_channel.send_embed('goodbye! D:') do |embed|
            embed.timestamp = Time.now

            embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: event.user.avatar_url)
            embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Member Count: #{event.server.member_count}")
            embed.add_field(name: 'a user has left! D:', value: "so long,\n**#{event.user.username}##{event.user.tag}**!")
          end
        end
      end
    end
  end
end
