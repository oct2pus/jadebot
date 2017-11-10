module Bot::Responses
    module OwO
        extend Discordrb::EventContainer
        message(contains: /owo/i) do |event|
            event.send_message('whats this :o')
        end
    end
end
