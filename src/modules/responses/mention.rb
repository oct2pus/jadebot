module Bot
  module Responses
    # responds back if a user pings her with "whats up :?"
    module Mention
      extend Discordrb::EventContainer
      mention do |event|
        server_settings = JSON.parse(Re::DIS.get("#{event.server.id}:SETTINGS"))
        if server_settings['interaction'] > 0
          Bot::JADE.send_message(event.channel, 'whats up :?')
          Bot::JADE.send_message(event.channel, "oh, my command prefix is `#{Pre::FIX}`\n just thought you might want to know :P")
        end
      end
    end
  end
end
