module Bot
  module Responses
    # jadebot starts Thinking if you send :thinking:, :blobthinking:
    # or :jadethinking:
    # server of origin for emoji is bot.jade.moe
    module Thinking
      extend Discordrb::EventContainer
      message(contains: [/🤔/, /<:blobthinking/, /<:jadethinking/]) do |event|
        if Bot::JADE.profile.on(event.server).permission?(:use_external_emoji)
          event.send_message('<:jadethinking:395982297490522122>') if Bot::JADE.profile.on(event.server).permission?(:send_messages)
        end
      end
    end
  end
end
