#command creates an invite to the bot.jade.moe discord

module Bot::Commands
    module Discord
        extend Discordrb::Commands::CommandContainer
        command :discord do |event|
            event << "https://discord.gg/D3vJQQF"
        end
    end
end
