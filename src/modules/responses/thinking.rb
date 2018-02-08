module Bot
  module Responses
    # jadebot starts Thinking if you send :thinking:, :blobthinking:
    # or :jadethinking:
    # server of origin for emoji is bot.jade.moe
    module Thinking
      extend Discordrb::EventContainer
      message(contains: [/🤔/, /<:blobthinking/, /<:jadethinking/]) do |event|
        if Bot::JADE.profile.on(event.server).permission?(:use_external_emoji)
          server_settings = JSON.parse($Redis.get("#{event.server.id}:SETTINGS"))
          if server_settings['interaction'] > 0
            event.send_message('<:jadethinking:395982297490522122>')
          end
        end
      end
    end
  end
end
