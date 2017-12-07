
require 'ruby_cowsay'
require 'fortune_gem'

module Bot
  module Commands
    # command prints a 'cowsay' message, default prints fortune
    module Cowsay 
      extend Discordrb::Commands::CommandContainer
      command :cowsay do |event, message|
        event << if message.nil? || event.content.include?('`')
                   "```#{Cow.new.say(FortuneGem.give_fortune)}```"
                 else
                   "```#{Cow.new.say(event.content[8..event.content.size])}```"
                 end
      end
    end
  end
end
