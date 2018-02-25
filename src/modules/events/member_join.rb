module Bot
  module Events
    # event logs every time a user joins as well as publically annouces it
    module MemberJoin
      extend Discordrb::EventContainer
      member_join do |event|
        server_settings = JSON.parse(Re::DIS.get("#{event.server.id}:SETTINGS"))
        if server_settings['greet']
          channel_id = server_settings['greeting_channel']
          default_channel = event.server.text_channels.find { |c| c.id.to_s == channel_id }
          default_channel = event.server.default_channel if default_channel.nil?
          # event.server.default_channel.send_embed("hello! :D") do |embed|
          default_channel.send_embed(server_settings['greeter_message']) do |embed|
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
# TODO: rewrite member_join and member_leave to be more modular