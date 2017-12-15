module Bot
    module Events
      # runs when a discord heartbeat occurs, mentions the heartbeat occurs to
      # help me track when errors occur, also updates Jadebots "GAME" to the
      # number of server she's running on currently.
        module HeartBeat
            extend Discordrb::EventContainer
            heartbeat do |_event|
                puts "Heartbeat at #{Time.now}"
                Bot::JADE.game = "Running on #{Bot::JADE.servers.size} servers."
            end
        end
    end
end