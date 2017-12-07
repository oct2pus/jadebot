# jade responds with :jadeteefs: if a user enters :blobteefs: or :jadeteefs:

module Bot
  module Responses
    module KissJade
      extend Discordrb::EventContainer
      message(contains: [/<:blobteefs/, /<:jadeteefs/]) do |event|
        if Bot::JADE.profile.on(event.server).permission?(:use_external_emoji)
          event.send_message('<:jadeteefs:317080214364618753>')
        end``
      end
    end
  end
end
