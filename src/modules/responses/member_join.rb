module Bot::Responses
    module Member_Join
        extend Discordrb::EventContainer
        member_join() do |event|
            Bot::JADE.send_message(event.server.default_channel(),"hey **#{event.user.username}**, welcome to **#{event.server.name}**! :D")
        end
    end
end
