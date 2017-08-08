require 'discordrb'
require 'configatron'
require_relative 'config.rb'

##Globals

jade = Discordrb::Commands::CommandBot.new token: configatron.token, client_id: configatron.id, prefix: '>'

##Greeters

jade.member_join() do |event|
	jade.send_message(event.server.default_channel(),"hey #{event.user.mention}, welcome to **#{event.server.name}**! :D")
end

jade.member_leave() do |event|
	jade.send_message(event.server.default_channel(),"#{event.user.mention} left **#{event.server.name}**! D:")
end

##Other Responses

jade.message(contains: /love jade/i) do |event|
	event.send_message("i love you too #{event.user.mention}! :green_heart:")
end

jade.message(contains: /owo/i) do |event|
	event.send_message('whats this :o')
end

jade.mention() do |event|
	jade.send_message(event.channel, "whats up :?")
end

jade.message(contains: /good dog/i) do |event|
	event.send_message("best friend")
end

jade.command :roll do |event, dice_message|
	#vars
	eval_command = ['1']
	counter = 0
	roll_amount = 0
	roll_size = 0
	roll_mod = 0

	#process
	if dice_message != nil
		begin
			eval_command[counter] = dice_message[counter]
			puts "#{counter}: #{eval_command[counter]}"
			counter += 1
			puts "#{dice_message.size}"
		end while /d/i.match("#{dice_message[counter]}") and counter < dice_message.size()
	else
		event << "you didnt tell me what dice you wanted to roll :o"
		
	end
end

##initialize bot

jade.run