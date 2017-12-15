module Bot
  module Responses
    # jadebot writes "best friend" if someone has "good dog" in their message
    module GoodDog
      extend Discordrb::EventContainer
      message(contains: /good dog/i) do |event|
        event.send_message('best friend') if Bot::JADE.profile.on(event.server).permission?(:send_messages)
      end
    end
  end
end
