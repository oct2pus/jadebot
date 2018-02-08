module Bot
  module Commands
    # command posts a user avatar
    module Avatar
      extend Discordrb::Commands::CommandContainer
      command(:avatar, description: "gets a users avatar\nusage: >avatar `@user`\n please @ the user") do |event, user_chosen|
        unless user_chosen.nil?
          user_chosen = Bot::JADE.parse_mention(user_chosen)
        end

        if user_chosen.nil?
          event << 'please **mention** a valid user'
        else
          event.channel.send_embed("here is **#{user_chosen.on(event.server).display_name}**'s avatar!") do |embed|
            embed.title = 'View Source'
            embed.url = user_chosen.avatar_url
            embed.image = { url: user_chosen.avatar_url }
          end
        end
      end
    end
  end
end
