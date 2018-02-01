module Bot
  module Events
    # commands to run when bot starts running
    module StartUp
      extend Discordrb::EventContainer
      ready do |_event|
        redis = Redis.new
        puts "Total Number of Servers: #{Bot::JADE.servers.size}"
        puts 'Jadebot initalized!'
      end
    end
  end
end
``
