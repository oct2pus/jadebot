require 'json'
require 'redis'

#event logs every message and deletes them 5 hours later

module Bot::Events
	module Store
	extend Discordrb::EventContainer
		message() do |event|
			if Bot::JADE.profile.on(event.server).permission?(:manage_server) && Bot::JADE.profile.on(event.server).permission?(:manage_channels)
				redis = Redis.new
				message_hash = {:user => event.message.user.username, :tag => event.message.user.tag, :message => event.message.content, :avatar => event.message.user.avatar_url}
				redis.set event.message.id, message_hash.to_json
				redis.expire(event.message.id, 18000) #in seconds, equal to five hours
				redis.close
			end
		end
	end
end
