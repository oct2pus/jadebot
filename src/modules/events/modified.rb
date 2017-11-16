require 'json'
require 'redis'

#event called every time a message is edited

module Bot::Events
    module Modified
        extend Discordrb::EventContainer
        message_edit() do |event|
            mod_log =  event.server.text_channels.find { |c| c.name == 'mod-log' }
            if mod_log == nil
                if Bot::JADE.profile.on(event.server).permission?(:manage_server)
                    mod_log = event.server.create_channel('mod-log')
                end
            end
            if Bot::JADE.profile.on(event.server).permission?(:send_messages, mod_log)
                redis = Redis.new
                if redis.get(event.message.id) != nil
                    original_message = JSON.parse(redis.get(event.message.id))
                    mod_log.send_embed do |embed|
                          embed.title = "Message Edited"
                            embed.description = "**#{event.user.username}##{event.user.tag}** has edited a message in **##{event.channel.name}**"
                            embed.timestamp = Time.now
                            embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{Bot::JADE.profile.username}", icon_url: "#{Bot::JADE.profile.avatar_url}")
                            
                            embed.add_field(name: "Original Message", value: "#{original_message['message']}")
                            embed.add_field(name: "New Message", value: "#{event.message}")
                    end
                else
                    mod_log.send_embed do |embed|
                            embed.description = "**#{event.user.username}##{event.user.tag}** has edited a message in **##{event.channel.name}**"
                            embed.timestamp = Time.now
                            embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{Bot::JADE.profile.username}", icon_url: "#{Bot::JADE.profile.avatar_url}")

                            embed.add_field(name: "Original Message Not Stored", value: "Message was not found in #{Bot::JADE.profile.username}'s Database")
                            embed.add_field(name: "New Message", value: "#{event.message}")
                    end
                end
            end
        end
    end
end
