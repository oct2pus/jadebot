module Bot::Commands
    module Ban
        extend Discordrb::Commands::CommandContainer
        command :ban do |event, user_chosen|
            if event.user.permission?(:ban_members)
                if Bot::JADE.parse_mention(user_chosen)
                    event << "**#{Bot.JADE.parse_mention(user_chosen).username}** has been banned from the server :p"
                    event.server.ban(Bot.JADE.parse_mention(user_chosen))
                else
                    event << "please **mention** a valid user"
                end
            else
                event << "you dont have permission to do that! >:Y"
            end
        end
    end
end
