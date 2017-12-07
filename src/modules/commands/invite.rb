module Bot
  module Commands
    # command creates an invite link for jadebot for users to invite her to their discord servers
    module Invite
      extend Discordrb::Commands::CommandContainer
      command :invite do |event|
        event << '<https://discordapp.com/oauth2/authorize?client_id=331204502277586945&scope=bot&permissions=3126>'
      end
    end
  end
end
