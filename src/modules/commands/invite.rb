module Bot::Commands
    module Invite
        extend Discordrb::Commands::CommandContainer
        command :invite do |event|
            event << "https://discordapp.com/oauth2/authorize?client_id=331204502277586945&scope=bot&permissions=314368"
        end
    end
end
    
