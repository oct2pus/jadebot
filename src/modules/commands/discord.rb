module Bot::Commands
    module Discord
        extend Discordrb::Commands::CommandContainer
        command :discord do |event|
            event << "https://discord.gg/D3vJQQF"
        end
    end
end
