module Bot
  module Responses
    # responds back if a user pings her with "whats up :?"
    module Mention
      extend Discordrb::EventContainer
      mention do |event|
        Bot::JADE.send_message(event.channel, 'whats up :?')
      end
    end
  end
end
