#event logs every time a user joins as well as publically annouces it

module Bot::Events
	module Member_Join
		extend Discordrb::EventContainer
		member_join() do |event|
			if Bot::JADE.profile.on(event.server).permission?(:use_voice_activity)	#temporary workaround until I implement proper json and by-server permissions
				message = Bot::JADE.send_message(event.server.default_channel(),"hey **#{event.user.username}**, welcome to **#{event.server.name}**! :D")
			end
			if Bot::JADE.profile.on(event.server).permission?(:manage_server) && Bot::JADE.profile.on(event.server).permission?(:manage_channels)
				mod_log = event.server.text_channels.find { |c| c.name == 'mod-log' }
				if mod_log == nil
					mod_log = event.server.create_channel("mod-log")
 				end
				if Bot::JADE.profile.on(event.server).permission?(:send_messages, mod_log)
					mod_log.send_embed do |embed|
						embed.title = "A User Joined The Server"
						embed.description = "**#{event.user.username}##{event.user.tag}** has joined **##{event.server.name}**"
						embed.timestamp = Time.now
						embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{event.user.username}##{event.user.tag}", icon_url: "#{event.user.avatar_url}")
					end
				end
			end
		end
	end
end
