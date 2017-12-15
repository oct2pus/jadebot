module Bot
  module Responses
    # says "whats this :o" if a user includes "owo" in their message
    module OwO
      extend Discordrb::EventContainer
      message(contains: /\bowo\b/i) do |event|
        event.send_message('whats this :o') Bot::JADE.profile.on(event.server).permission?(:send_messages)
      end
    end
  end
end
