# command kicks a user from the server, requires user to have "kick members" permission

module Bot::Commands
  module Kick
    extend Discordrb::Commands::CommandContainer
    command :kick do |event, user_chosen|
      if event.user.permission?(:kick_members)
        if Bot::JADE.parse_mention(user_chosen)
          event << "**#{Bot::JADE.parse_mention(user_chosen).username}** has been kicked from the server :p"
          event.server.kick(Bot::JADE.parse_mention(user_chosen))
        else
          event << 'please **mention** a valid user'
          end
      else
        event << 'you dont have permission to do that! >:Y'
      end
    end
  end
end
