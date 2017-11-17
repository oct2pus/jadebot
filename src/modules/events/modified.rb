require 'json'
require 'redis'

#event called every time a message is edited

module Bot::Events
	module Modified
		extend Discordrb::EventContainer
		message_edit() do |event|
			mod_log =  event.server.text_channels.find { |c| c.name == 'mod-log' }
			if mod_log == nil
				if Bot::JADE.profile.on(event.server).permission?(:manage_server)
					mod_log = event.server.create_channel('mod-log')
				end
			end
			if Bot::JADE.profile.on(event.server).permission?(:send_messages, mod_log)
				redis = Redis.new
				if redis.get(event.message.id) != nil
					stored_message = JSON.parse(redis.get(event.message.id))
					mod_log.send_embed do |embed|
							embed.title = "Message Edited"
							embed.description = "a message has been edited in <##{event.channel.id}>"
							embed.timestamp = Time.now
							embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{event.user.username}##{event.user.tag}", icon_url: "#{event.user.avatar_url}")
							embed.add_field(name: "Previous Message", value: "#{stored_message['message']}")
							embed.add_field(name: "Current Message", value: "#{event.message}")
					end
					stored_message['message'] = event.message
				else
					mod_log.send_embed do |embed|
							embed.description = "a message has been edited in <##{event.channel.id}>"
							embed.timestamp = Time.now
							embed.author = Discordrb::Webhooks::EmbedAuthor.new(name:	"#{Bot::JADE.profile.username}", icon_url: "#{Bot::JADE.profile.avatar_url}")
							embed.add_field(name: "Previous Message Not Stored", value: "Message was not	found in #{Bot::JADE.profile.username}'s Database")
							embed.add_field(name: "Current Message", value: "#{event.message}")
					end
					stored_message = {:user => event.message.user.username, :tag => event.message.user.tag, :message => event.message.content, :avatar => event.message.user.avatar_url}
				end
				redis.set event.message.id, stored_message.to_json
				redis.expire(event.message.id, 18000) #in seconds, equal to five hours
			end
		end
	end
end
