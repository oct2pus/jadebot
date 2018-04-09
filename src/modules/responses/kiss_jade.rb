module Bot
  module Responses
    # if someone uses a :kissjade: emoji, she responds with two emojis
    # only works if the server has a :kissjade: emote
    module KissJade
      extend Discordrb::EventContainer
      message(contains: /<:kissjade/) do |event|
        server_settings = JSON.parse(Re::DIS.get("#{event.server.id}:SETTINGS"))
        if server_settings['interaction'] == 2
          event.send_message('<:jb_embarassed:432675788698157056><:jade_hearts:432685108085129246>')
        end
      end
    end
  end
end
