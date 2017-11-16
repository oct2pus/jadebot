#https://github.com/oct2pus/jadebot/blob/master/STORAGE_POLICY.md
module Bot::Events
    module Inform
        extend Discordrb::EventContainer
        ready() do |event|
            Bot::JADE.servers.each do |server|
               Bot::JADE.send_message(server[1].default_channel(),  "hey @everyone i am now storing messages users send, please read <https://github.com/oct2pus/jadebot/blob/master/STORAGE_POLICY.md> for more information!")
            end
        end
    end
end
