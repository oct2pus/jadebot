module Bot
  module Commands
    # command posts a user avatar
    module Avatar
      extend Discordrb::Commands::CommandContainer
      command :avatar do |event, user_chosen|
        if !user_chosen.nil?
          user_chosen = Bot::JADE.parse_mention(user_chosen)
          message_string = "here is #{user_chosen.on(event.server).display_name}'s avatar :o"
        else
          user_chosen = event.user
          message_string = "here is your avatar, #{event.user.display_name} :D"
        end

        if user_chosen
          event.channel.send_embed(message_string) do |embed|
            embed.title = 'View Source'
            embed.url = user_chosen.avatar_url
            embed.image = { url: user_chosen.avatar_url }
          end
        else
          event << 'please **mention** a valid user'
        end
      end
      end
  end
end
