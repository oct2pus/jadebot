module Bot::Responses
    module Kiss_Jade
        extend Discordrb::EventContainer
        message(contains: /<:blobteefs/) do |event|
            event.send_message("<:jadeteefs:317080214364618753>")
        end
    end
end
