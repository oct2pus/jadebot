module Bot::Events
    module Deleted
        extend Discordrb::EventContainer
        message_delete() do |event|
            mod_log =  event.channel.server.text_channels.find { |c| c.name == 'mod-log' }
            if mod_log == nil
                if Bot::JADE.profile.on(event.server).permission?(:manage_server)
                    mod_log = event.channel.server.create_channel("mod-log")
                end
            end
            if Bot::JADE.profile.on(event.channel.server).permission?(:send_messages, mod_log)
                Bot::JADE.send_message(mod_log,"a message has deleted a message in **##{event.channel.name}**")
            end
        end
    end
end
