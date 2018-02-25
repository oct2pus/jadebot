module Bot
  module Responses
    # jadebot writes "best friend" if someone has "good dog" in their message
    module GoodDog
      extend Discordrb::EventContainer
      message(contains: /good dog/i) do |event|
        server_settings = JSON.parse(Re::DIS.get("#{event.server.id}:SETTINGS"))
        event.send_message('best friend') if server_settings['interaction'] > 0
      end
    end
  end
end
