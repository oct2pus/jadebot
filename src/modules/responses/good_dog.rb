module Bot
  module Responses
    # jadebot writes "best friend" if someone has "good dog" in their message
    module GoodDog
      extend Discordrb::EventContainer
      message(contains: /good dog/i) do |event|
        event.send_message('best friend')
      end
    end
  end
end
