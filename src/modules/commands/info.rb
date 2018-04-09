module Bot
  module Commands
    # command posts a user avatar
    module Info
      extend Discordrb::Commands::CommandContainer
      Bot::JADE.bucket :info_b, limit: 1, time_span: 20
      command(:info, bucket: :info_b, description: 'displays information about jadebot!') do |event|
        event.channel.send_embed do |embed|
          embed.title = 'Jadebot Development Information'
          embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "#{Bot::JADE.profile.avatar_url.gsub('.webp', '.png')}")
          embed.add_field(name: 'Developer:', value: "**Discord**: *🐙🐙#0413*\n**Tumblr**: https://oct2pus.tumblr.com\n**Mastodon**: https://im-in.space/@oct2pus\n**Github**: https://github.com/oct2pus/\n")
          embed.add_field(name: 'Discord Library:', value: "Discordrb: https://github.com/meew0/discordrb", inline: true)
          embed.add_field(name: 'Special Thanks:', value: "*tjb#0607* (https://blog.tjb.me) for his contributions\n*taiyoooh* (https://taiyoooh.tumblr.com/) for Jadebot's avatar\n*Andrew Hussie* (https://homestuck.com) for creating Homestuck\n*Jade Harley* for being herself!")
          embed.add_field(name: 'Disclaimer:"', value: "Jadebot uses **Mutant Standard Emoji** (https://mutant.tech) made by *Dzuk#1671*\n**Mutant Standard Emoji** are licensed under CC-BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/) ")
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(icon_url: 'https://raw.githubusercontent.com/oct2pus/jadebot/master/src/art/jade_heart.png',text: " Prefix: #{Pre::FIX} | Servers: #{Bot::JADE.servers.size}")
        end
      end
    end
  end
end
