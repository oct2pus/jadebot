# frozen_string_literal: true

module Bot
  module Commands
    # command prints a 'cowsay' message, default prints fortune
    module Cowsay
      extend Discordrb::Commands::CommandContainer
      Bot::JADE.bucket :moo_b, limit: 2, time_span: 15, delay: 5
      command(:cowsay, bucket: :moo_b, rate_limit_message: 'give the cow %time% more seconds to recover her voice >:U', description: "moo\nusage: #{Pre::FIX}cowsay `any message here`\ncowsay without a message will post a random UNIX fortune") do |event, *args|
        event << if args.empty? || args.any? { |word| word.include? '`' }
                   "```#{Cow.new.say(FortuneGem.give_fortune)}```"
                 else
                   message = args.join(' ')
                   "```#{Cow.new.say(message)}```"
                 end
      end
    end
  end
end
