require 'json'
require 'redis'

#event logs every message and deletes them 5 hours later

module Bot::Events
    module Store
        extend Discordrb::EventContainer
        message() do |event|
            redis = Redis.new
            message_hash = {:user => event.message.user.username, :tag => event.message.user.tag, :message => event.message.content}
            redis.set event.message.id, message_hash.to_json
            redis.expire(event.message.id, 18000) #in seconds, equal to five hours
            redis.close
        end
    end
end
