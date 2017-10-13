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
	result_message = "you rolled a "
	#process
	if dice_message != nil
		puts "===="
		
		
		#parse dice roll
		begin			
			eval_command[counter_eval] = dice_message[counter_message]
			puts "#{counter_eval}: #{dice_message[counter_message]}"
			
			if dice_message[counter_message+1] == "d" and !d_pass
				roll_amount = eval_command.to_i
				puts "roll amount = #{roll_amount}"
				eval_command = ""
				counter_eval = -1
				counter_message += 1
				d_pass = true
			end
			
			if dice_message[counter_message+1] =~ /([+-])/
				if dice_message[counter_message+1] == "-"
					math_type = false
				end
				
				roll_size = eval_command.to_i
				puts "roll size = #{roll_size}"
				eval_command = ""
				counter_eval = -1
				counter_message += 1
				math_pass = true
			end
			
			counter_message += 1
			counter_eval += 1
		end while counter_message < dice_message.size()
		
		if !math_pass
			roll_size = eval_command.to_i
			puts "roll size = #{roll_size}"
		else math_pass == true
			if !math_type
				roll_mod -= eval_command.to_i
			else 
				roll_mod += eval_command.to_i
			end
			
			puts "roll mod = #{roll_mod}"
		end
		
		puts "====\n"
		
	i = 0
		until i >= roll_amount
			result[i] = rand(roll_size) + 1
			result_total+= result[i]
			
			result_message << "#{result[i]}, "
			i += 1
		end
			
			result_total += roll_mod
			result_message << "and with a modifier of #{roll_mod} you get: #{result_total}"
		if result_message.size() <= 1000
			event << result_message
		else
			event << "woah fuckass you just passed discord message limit with that roll >:U"
		end
	else
		event << "you didnt tell me what dice you wanted to roll :o"
	end
end

##initialize bot

jade.run
