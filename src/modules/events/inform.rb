#https://github.com/oct2pus/jadebot/blob/master/STORAGE_POLICY.md
module Bot::Events
    module Inform
        extend Discordrb::EventContainer
        ready() do |event|
            Bot::JADE.send_message(Bot::JADE.server.default_channel(), "hey @everyone i am now storing messages users send, please read <https://github.com/oct2pus/jadebot/blob/master/STORAGE_POLICY.md> for more information!")
        end
    end
end
