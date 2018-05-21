# frozen_string_literal: true

module Bot
  module Responses
    # jade responds with :jadeteefs: if a user enters :blobteefs: or
    # :jadeteefs:
    module TeefJade
      extend Discordrb::EventContainer
      message(contains: [/<:blobteefs/, /<:jadeteefs/, /<:teefs/]) do |event|
        if Bot::JADE.profile.on(event.server).permission?(:use_external_emoji)
          server_settings = JSON.parse(Re::DIS.get("#{event.server.id}:SETTINGS"))
          if server_settings['interaction'] > 0
            event.send_message('<:jadeteefs:317080214364618753>')
          end
        end
      end
    end
  end
end
