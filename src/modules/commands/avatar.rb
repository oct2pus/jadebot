# frozen_string_literal: false

module Bot
  module Commands
    # command posts a user avatar
    module Avatar
      extend Discordrb::Commands::CommandContainer
      Bot::JADE.bucket :avatar_b, limit: 3, time_span: 20, delay: 5
      command(:avatar, bucket: :avatar_b, rate_limit_message: 'slowdown fuckass! wait %time% more seconds before doing that again', description: "gets a users avatar\nusage: #{Pre::FIX}avatar `user-nickname`\n#{Pre::FIX}avatar `@user`") do |event, *args|
        user_chosen = args.join(' ')

        if Bot::JADE.parse_mention(user_chosen)
          user = Bot::JADE.parse_mention(user_chosen).on(event.server)
        elsif !user_chosen.nil?
          user = Jb.fuzz(event, user_chosen)
        end

        display_name = Jb.sanitize(user.display_name)

        if user_chosen.nil?
          event.channel.send_embed('here is **your** avatar!') do |embed|
            embed.title = 'View Source'
            embed.url = event.user.avatar_url.gsub('.webp', '.png')
            embed.image = { url: event.user.avatar_url.gsub('.webp', '.png') }
          end
        else
          event.channel.send_embed("here is **#{display_name}**'s avatar!") do |embed|
            embed.title = 'View Source'
            embed.url = user.avatar_url.gsub('.webp', '.png')
            embed.image = { url: user.avatar_url.gsub('.webp', '.png') }
          end
        end
      end
    end
  end
end
