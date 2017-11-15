#if a user enters "love jade" or "love you jade" jade will mention she loves the user back, fulfills the "TJB" clause

module Bot::Responses
    module Love_You
        extend Discordrb::EventContainer
        message(contains: /love( you,?)? jade/i) do |event|
            event.send_message("i love you too #{event.user.mention}! :green_heart:")
        end
    end
end
