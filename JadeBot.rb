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

jade.message(contains: /love( you,?)? jade/i) do |event|
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

jade.message(contains: /<:kissjade/) do |event|
    event.send_message(":flushed::two_hearts:")
end

jade.command :github do |event|
	event << "feel free to contribute to my codebase at https://github.com/oct2pus/jadebot! :D"
end

jade.command :invite do |event|
	event << "https://discordapp.com/oauth2/authorize?client_id=331204502277586945&scope=bot&permissions=314368"
end

jade.command :roll do |event, dice_message|
	#todo: make a prettier output
	
	#vars
	eval_command = ""
	counter_message = 0
	counter_eval = 0
	roll_amount = 0
	roll_size = 0
	roll_mod = 0
	d_pass = false
	math_pass = false
	math_type = true	#determines if modifier is positive or negative
	result = {}
	result_total = 0
	result_message = "you rolled ```"
	
	#process
	if (dice_message =~ /[0-9]+d[0-9]+((\+|-)[0-9])?/)
		
		#parse dice roll
		begin			
			eval_command[counter_eval] = dice_message[counter_message]			
			
			if dice_message[counter_message+1] == "d" and !d_pass
				roll_amount = eval_command.to_i.abs

				eval_command = ""
				counter_eval = -1
				counter_message += 1
				d_pass = true
			end
			
			if dice_message[counter_message+1] =~ /([+-])/
				if dice_message[counter_message+1] == "-"
					math_type = false
				end
				
				roll_size = eval_command.to_i.abs

				eval_command = ""
				counter_eval = -1
				counter_message += 1
				math_pass = true
			end
			
			counter_message += 1
			counter_eval += 1
		end while counter_message < dice_message.size()
		
		if !math_pass
			roll_size = eval_command.to_i.abs
			
		else math_pass == true
			if !math_type
				roll_mod -= eval_command.to_i
			else 
				roll_mod += eval_command.to_i
			end

		end
		
 		if roll_amount > 100
			event << "sorry that many die will make my processor cry\nyou can only roll up to 100 die >:U"
			break
		elsif roll_size == 0 or roll_amount == 0
			event << "please dont be a smartass"
			break
		end
		
		i = 0
		until i >= roll_amount
			result[i] = rand(roll_size) + 1
			result_total+= result[i]
			
			result_message << "#{result[i]} "
			i += 1
		end
			
		result_total += roll_mod
		result_message << "```and with a modifier of #{roll_mod} you get: #{result_total}"
		
		if result_message.size() <= 1000
			event << result_message
		else
			event << "woah fuckass you just passed discord message limit with that roll >:U"
		end
	elsif dice_message == nil
		event << "you didnt tell me what dice you wanted to roll :o"
	else
		event << "please use the XXdXX format, with XX being any number :D"
	end
end

##initialize bot

jade.run
