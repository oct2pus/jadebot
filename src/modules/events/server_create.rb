require 'redis'

module Bot
  module Events
    # commands to run when bot starts running
    module ServerCreate
      extend Discordrb::EventContainer
      server_create do |_event|
        redis = Redis.new
        redis.set '{event.server.id}:GREETER', true
        redis.set '{event.server.id}:GREETER_CHANNEL', event.server.default_channel.id
      end
    end
  end
end
