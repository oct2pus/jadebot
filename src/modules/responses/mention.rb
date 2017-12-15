module Bot
  module Responses
    # responds back if a user pings her with "whats up :?"
    module Mention
      extend Discordrb::EventContainer
      mention do |event|
        Bot::JADE.send_message(event.channel, 'whats up :?') Bot::JADE.profile.on(event.server).permission?(:send_messages)
      end
    end
  end
end
