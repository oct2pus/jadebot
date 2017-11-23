#command prints a 'cowsay' message, default prints fortune

require 'ruby_cowsay'
require 'fortune_gem'

module Bot::Commands
	module Cowsay
		extend Discordrb::Commands::CommandContainer
		command :cowsay do |event, message|
			if message == nil || event.content.include?("`")
				event << "```#{Cow.new.say(FortuneGem.give_fortune)}```"
			else
				event << "```#{Cow.new.say(event.content[8..event.content.size])}```"
			end
		end
	end
end
			
