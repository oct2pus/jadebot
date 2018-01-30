require 'ruby_cowsay'
require 'fortune_gem'

module Bot
  module Commands
    # command prints a 'cowsay' message, default prints fortune
    module Cowsay
      extend Discordrb::Commands::CommandContainer
      command(:cowsay, description: "moo\nusage: >cowsay `any message here`\ncowsay without a message will post a random UNIX fortune") do |event, *args|
        event << if args.empty? || args.any? { |word| word.include? '`'}
                   "```#{Cow.new.say(FortuneGem.give_fortune)}```"
                 else
                    message = args.join(' ')
                   "```#{Cow.new.say(message)}```"
                 end
      end
    end
  end
end
