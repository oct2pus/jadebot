#event logs every time a user leaves as well as publically annouces it

module Bot::Events
	module Member_Leave
		extend Discordrb::EventContainer
		member_leave() do |event|
			mod_log =  event.server.text_channels.find { |c| c.name == 'mod-log' }
			message = Bot::JADE.send_message(event.server.default_channel(),"**#{event.user.username}** has left **#{event.server.name}**! D:")
			if mod_log == nil
				if Bot::JADE.profile.on(event.server).permission?(:manage_server)
					mod_log = event.server.create_channel("mod-log")
				end
			end
			if Bot::JADE.profile.on(event.server).permission?(:send_messages, mod_log)
				mod_log.send_embed do |embed|
					embed.title = "A User Left The Server"
					embed.description = "**#{event.user.username}##{event.user.tag}** has left **##{event.server.name}**"
					embed.timestamp = Time.now
					embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{event.user.username}##{event.user.tag}", icon_url: "#{event.user.avatar_url}")
				end
			end
		end
	end
end
