module Bot::Events
    module Member_Leave
        extend Discordrb::EventContainer
        member_leave() do |event|
            mod_log =  event.server.text_channels.find { |c| c.name == 'mod-log' }
            Bot::JADE.send_message(event.server.default_channel(),"**#{event.user.username}** has left **#{event.server.name}**! D:")
            if mod_log == nil
                if Bot::JADE.profile.on(event.server).permission?(:manage_channels)
                    mod_log = event.server.create_channel("mod-log")
                end
            end
            if Bot::JADE.profile.on(event.server).permission?(:send_messages, mod_log)
                Bot::JADE.send_message(mod_log,"**#{event.user.username}##{event.user.tag}** has left **#{event.server.name}**")
            end
        end
    end
end
