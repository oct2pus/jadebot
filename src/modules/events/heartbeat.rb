# frozen_string_literal: true

module Bot
  module Events
    # runs when a discord heartbeat occurs, mentions the heartbeat occurs to
    # help me track when errors occur, also updates Jadebots "GAME" to the
    # number of server she's running on currently.
    module HeartBeat
      extend Discordrb::EventContainer
      heartbeat do |_event|
        time = Time.now
        puts "\n========================"
        puts "Heartbeat at #{time}"
        puts "========================\n"
        Bot::JADE.game = if time.to_i.even?
                           "Running on #{Bot::JADE.servers.size} servers"
                         else
                           "My prefix is '#{Pre::FIX}'"
                         end
      end
    end
  end
end
