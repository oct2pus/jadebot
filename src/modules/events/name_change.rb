require 'redis'

module Bot
  module Events
    module Name_Change
      extend Discordrb::EventContainer
      member_update do |event|
        redis = Redis.new

        if redis.exists("#{event.server.id}:#{event.user.id}")
          user_nickname = redis.get("#{event.server.id}:#{event.user.id}")

          if user_nickname != event.user.display_name
            mod_log = event.server.text_channels.find { |c| c.name == 'mod-log' }
            mod_log = event.server.create_channel('mod-log') if mod_log.nil?

            if Bot::JADE.profile.on(event.server).permission?(:send_messages, mod_log)
              mod_log.send_embed do |embed|
                embed.title = 'A User Changed Their Nickname'
                embed.description = "**#{event.user.username}##{event.user.tag}** has changed their nickname."
                embed.timestamp = Time.now
                embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{event.user.username}##{event.user.tag}", icon_url: event.user.avatar_url.to_s)
                embed.add_field(name: 'Previous Nickname', value: user_nickname.to_s)
                embed.add_field(name: 'New Nickname', value: event.user.display_name.to_s)
              end
            end
          end
          redis.set "#{event.server.id}:#{event.user.id}", event.user.display_name

          redis.close
        end
      end
    end
  end
end
