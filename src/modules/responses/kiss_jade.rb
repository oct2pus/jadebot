#if someone uses a :kissjade: emoji, she responds with these two emojis

module Bot::Responses
    module Kiss_Jade
        extend Discordrb::EventContainer
        message(contains: /<:kissjade/) do |event|
			do_event = false

			event.server.emoji.each do |id, emoji|
				if emoji.name == "kissjade"
					do_event = true
					break
				end
			end

			if do_event
            	event.send_message(":flushed::two_hearts:")
			end
        end
    end
end
