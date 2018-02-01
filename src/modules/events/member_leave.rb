require 'redis'

module Bot
  module Events
    # event logs every time a user leaves as well as publically annouces it
    module MemberLeave
      extend Discordrb::EventContainer
      member_leave do |event|
        redis = Redis.new
        if redis.exists("#{event.server.id}:GREETER") && redis.get("#{event.server.id}:GREETER")
          channel_id = redis.get("#{event.server.id}:GREETER_CHANNEL").to_s
          default_channel = event.server.text_channels.find { |c| c.id.to_s == channel_id }
          if default_channel.nil?
            default_channel = event.server.default_channel
          end
          # event.server.default_channel.send_embed("goodbye! D:") do |embed|
          default_channel.send_embed('goodbye! D:') do |embed|
            embed.timestamp = Time.now

            embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: event.user.avatar_url)
            embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Member Count: #{event.server.member_count}")
            embed.add_field(name: 'a user has left! D:', value: "so long,\n**#{event.user.username}##{event.user.tag}**!")
          end
        end
        redis.close
      end
    end
  end
end
