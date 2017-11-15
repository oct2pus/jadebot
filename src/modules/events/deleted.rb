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
                    Bot::JADE.send_message(mod_log,"**#{original_message['user']}##{original_message['tag']}** has deleted a message in **##{event.channel.name}** at #{time}, original message below```#{original_message['message']}\n```")
                else    #fallback for a message thats not been stored
                    Bot::JADE.send_message(mod_log,"a message has deleted a message in **##{event.channel.name}** at #{time}")
                end
                redis.close
            end
        end
    end
end
