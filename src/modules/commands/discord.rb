module Bot
  module Commands
    # command creates an invite to the bot.jade.moe discord
    module Discord
      extend Discordrb::Commands::CommandContainer
      command :discord do |event|
        event << 'https://discord.gg/D3vJQQF'
      end
    end
  end
end
