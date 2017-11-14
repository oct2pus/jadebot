module Bot::Responses
    module Kiss_Jade
        extend Discordrb::EventContainer
        message(contains: /<:blobteefs/) do |event|
            event.send_message(":jadeteefs:")
        end
    end
end
