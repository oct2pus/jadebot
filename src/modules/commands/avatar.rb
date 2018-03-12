module Bot
  module Commands
    # command posts a user avatar
    module Avatar
      extend Discordrb::Commands::CommandContainer
      Bot::JADE.bucket :avatar_b, limit: 3, time_span: 20, delay: 5
      command(:avatar, bucket: :avatar_b, rate_limit_message: 'slowdown fuckass! wait %time% more seconds before doing that again', description: "gets a users avatar\nusage: #{Pre::FIX}avatar `@user`\n please @ the user") do |event, user_chosen|
        unless user_chosen.nil?
          user_chosen = Bot::JADE.parse_mention(user_chosen)
        end

        if user_chosen.nil?
          event.channel.send_embed('here is **your** avatar!') do |embed|
            embed.title = 'View Source'
            embed.url = event.user.avatar_url.gsub('.webp', '.png')
            embed.image = { url: event.user.avatar_url.gsub('.webp', '.png') }
          end
        else
          event.channel.send_embed("here is **#{user_chosen.on(event.server).display_name}**'s avatar!") do |embed|
            embed.title = 'View Source'
            embed.url = user_chosen.avatar_url.gsub('.webp', '.png')
            embed.image = { url: user_chosen.avatar_url.gsub('.webp', '.png') }
          end
        end
      end
    end
  end
end
