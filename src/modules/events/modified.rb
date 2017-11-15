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
                    Bot::JADE.send_message(mod_log,"**#{event.user.username}##{event.user.tag}** has edited a message in **##{event.channel.name}** at #{event.timestamp}\noriginal message```#{original_message['message']}\n```new message\n```#{event.message}```")
                else #fallback message if message was not stored
                    Bot::JADE.send_message(mod_log,"**#{event.user.username}##{event.user.tag}** has edited a message in **##{event.channel.name}** at #{event.timestamp}")
                end
            end
        end
    end
end
