require 'json'
require 'redis'
require 'sequel'

#event logs every message and deletes them 5 hours later
#manages leveling system

module Bot::Events
	module User_Post
	extend Discordrb::EventContainer
		message() do |event|
			if Bot::JADE.profile.on(event.server).permission?(:manage_server) && Bot::JADE.profile.on(event.server).permission?(:manage_channels)
				redis = Redis.new
				message_hash = {:user => event.message.user.username, :tag => event.message.user.tag, :message => event.message.content, :avatar => event.message.user.avatar_url}
				redis.set event.message.id, message_hash.to_json
				redis.expire(event.message.id, 18000) #in seconds, equal to five hours
				redis.close
			end
			if Bot::JADE.profile.on(event.server).permission?(:read_messages)
				levels = Bot::DB[:levels].where(user_id: event.message.user.id, server_id: event.server.id)
				if levels.empty?
					levels.insert(user_id: event.message.user.id, server_id: event.server.id, level: 1, xp: 0, to_next_level: 100)
				else
					user_level = levels.get(:level)
					user_xp = levels.get(:xp)
					user_next = levels.get(:to_next_level)
					
					user_xp += 10
					
					if user_xp >= user_next
						user_next = user_next + user_next
						user_level += 1
						event << "Level up!\n#{event.message.user.display_name} is now **Level #{user_level}**"
					end
					levels.update(level: user_level, xp: user_xp, to_next_level: user_next)
				end
			end
		end
	end
end
