require 'json'
require 'redis'

module Bot
  module Events
    # event logs every message and deletes them 5 hours later
    # event also manages leveling system
    module UserPost
      extend Discordrb::EventContainer
      message do |event|
        redis = Redis.new
        if Bot::JADE.profile.on(event.server).permission?(:manage_server) && Bot::JADE.profile.on(event.server).permission?(:manage_channels)
          message_hash = { user: event.message.user.username, tag: event.message.user.tag, message: event.message.content, avatar: event.message.user.avatar_url }
          redis.set event.message.id, message_hash.to_json
          redis.expire(event.message.id, 180_000) # in seconds, equal to a
          # little more than 41 hours
        end

        redis.close
      end
    end
  end
end
