module Bot::Responses
    module Member_Leave
        extend Discordrb::EventContainer
        member_leave() do |event|
            Bot::JADE.send_message(event.server.default_channel(),"**#{event.user.username}** left **#{event.server.name}**! D:")
        end
    end
end
