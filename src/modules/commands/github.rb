#command posts a link to the jadebot github page

module Bot::Commands
    module Github
        extend Discordrb::Commands::CommandContainer
        command :github do |event|
            event << "feel free to contribute to my codebase at <http://bot.jade.moe>! :D"
        end
    end
end
