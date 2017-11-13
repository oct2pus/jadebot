module Bot::Events
    module Modified
        extend Discordrb::EventContainer
        message_edit() do |event|
            mod_log =  event.server.text_channels.find { |c| c.name == 'mod-log' }
            if mod_log == nil
                if Bot::JADE.profile.on(event.server).permission?(:manage_channels)
                    mod_log = event.server.create_channel("mod-log")
                end
            end
            if Bot::JADE.profile.on(event.server).permission?(:send_messages, mod_log)
                Bot::JADE.send_message(mod_log,"**#{event.user.username}##{event.user.tag}** has edited a message in **##{event.channel.name}** at #{event.timestamp}")
            end
        end
    end
end
