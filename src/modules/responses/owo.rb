module Bot
  module Responses
    # says "whats this :o" if a user includes "owo" in their message
    module OwO
      extend Discordrb::EventContainer
      message(contains: /\bowo\b/i) do |event|
        server_settings = JSON.parse($Redis.get("#{event.server.id}:SETTINGS"))
        if server_settings['interaction'] > 0
          event.send_message('whats this :o')
        end
      end
    end
  end
end
