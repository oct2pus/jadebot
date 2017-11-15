#event logs every time a user joins as well as publically annouces it

module Bot::Events
    module Member_Join
        extend Discordrb::EventContainer
        member_join() do |event|
            mod_log =  event.server.text_channels.find { |c| c.name == 'mod-log' }
            message = Bot::JADE.send_message(event.server.default_channel(),"hey **#{event.user.username}**, welcome to **#{event.server.name}**! :D")
            if mod_log == nil
                if Bot::JADE.profile.on(event.server).permission?(:manage_server)
                    mod_log = event.server.create_channel("mod-log")
                end
            end
            if Bot::JADE.profile.on(event.server).permission?(:send_messages, mod_log)
                Bot::JADE.send_message(mod_log,"**#{event.user.username}##{event.user.tag}** has joined **#{event.server.name}** at #{message.timestamp}")
            end
        end
    end
end
