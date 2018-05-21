# frozen_string_literal: true

module Bot
  module Responses
    # if a user enters "love jade" or "love you jade" jade will mention she
    # loves the user back, fulfills the "TJB" clause
    module LoveYou
      extend Discordrb::EventContainer
      message(contains: /love( you,?)? jade/i) do |event|
        server_settings = JSON.parse(Re::DIS.get("#{event.server.id}:SETTINGS"))
        if server_settings['interaction'] == 2
          event.send_message("i love you too, #{event.user.mention}! <:jade_heart:432685108231667712>")
        end
      end
    end
  end
end
