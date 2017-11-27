#says "whats this :o" if a user includes "owo" in their message

module Bot::Responses
    module OwO
        extend Discordrb::EventContainer
        message(contains: /\bowo\b/i) do |event|
            event.send_message("whats this :o")
        end
    end
end
