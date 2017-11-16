require 'json'
require 'redis'

#event logs every time a message is deleted and displays the message that was deleted in the mod-log

module Bot::Events
    module Deleted
        extend Discordrb::EventContainer
        message_delete() do |event|
            mod_log =  event.channel.server.text_channels.find { |c| c.name == 'mod-log' }
            if mod_log == nil
                if Bot::JADE.profile.on(event.server).permission?(:manage_server)
                    mod_log = event.channel.server.create_channel('mod-log')
                end
            end
            if Bot::JADE.profile.on(event.channel.server).permission?(:send_messages, mod_log)
                redis = Redis.new
                time = Time.new
                if redis.get(event.id) != nil
                    original_message = JSON.parse(redis.get(event.id))
                    mod_log.send_embed do |embed|
                        embed.title = "Message Deleted"
                        embed.description = "**#{original_message['user']}##{original_message['tag']}** has deleted a message in **##{event.channel.name}**"
                        embed.timestamp = Time.now
                        embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{Bot::JADE.profile.username}", icon_url: "#{Bot::JADE.profile.avatar_url}")
                        
                        embed.add_field(name: "Deleted Message", value: "#{original_message['message']}")
                    end
                else   
                    mod_log.send_embed do |embed|
                        embed.title = "Message Deleted"
                        embed.description = "A user has a deleted a message in **##{event.channel.name}**"
                        embed.timestamp = Time.now
                        embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{Bot::JADE.profile.username}", icon_url: "#{Bot::JADE.profile.avatar_url}")
                        
                        embed.add_field(name: "Deleted Message Not Stored", value: "Message was not found in #{Bot::JADE.profile.username}'s Database")
                    end
                end
                redis.close
            end
        end
    end
end
