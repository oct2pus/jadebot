module Bot
  module Responses
    # if someone uses a :kissjade: emoji, she responds with two emojis
    # only works if the server has a :kissjade: emote
    module KissJade
      extend Discordrb::EventContainer
      message(contains: /<:kissjade/) do |event|
        do_event = false

        event.server.emoji.each do |_id, emoji|
          if emoji.name == 'kissjade'
            do_event = true
            break
          end
        end

        event.send_message(':flushed::two_hearts:') if do_event
      end
    end
  end
end
