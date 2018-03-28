module Bot
  module Commands
    # command searches the MSPABooru and display a random result from the first
    # 25 images grabbed
    module Mspa
      extend Discordrb::Commands::CommandContainer
      Bot::JADE.bucket :mspa_b, limit: 4, time_span: 45, delay: 7
      command(:mspa, bucket: :mspa_b, rate_limit_message: "please slow down!\nwait another %time% seconds :p", description: "searches and posts images from mspabooru\n usage: #{Pre::FIX}mspa `any-tags-here`\ntags are split by spaces, multiple word tags are split with '_'\nexample: `#{Pre::FIX}mspa dave_strider kiss karkat_vantas shipping`\nkeep in mind mspabooru uses some funky search tags for ships, here is a list of (almost) every ship name: <https://docs.google.com/spreadsheets/d/1IR5mmxNxgwAqH0_VENC0KOaTgSXE_azPts8qwqz9xMk>") do |event, *args|
        server_settings = JSON.parse(Re::DIS.get("#{event.server.id}:SETTINGS"))
        parser = Nori.new
        limit = 25
        pid = 0
        url = 'http://mspabooru.com//index.php?page=dapi&s=post&q=index'
        url << "&pid=#{pid}&limit=#{limit}"
        unless args.empty?
          url << '&tags='
          args.each do |tag|
            url << "#{tag}+"
          end
        end

        server_settings['mspa'].size
        unless server_settings['mspa'].empty?
          url << '&tags=' if args.empty?
          url << "-#{server_settings['mspa'].join('+-')}"
          unless event.channel.nsfw?
            url << "+-bondage+-dubcon+-mind_control+-undergarments+-rating:questionable+-rating:explicit"
          end
        end

        begin
          output = parser.parse(RestClient.get(url))

          if limit > output['posts']['@count'].to_i
            limit = output['posts']['@count'].to_i - 1
          end
          if limit != 0
            img_no = rand(limit)
            event.channel.send_embed('here you go! :u') do |embed|
              embed.title = 'View Source'
              embed.url = output['posts']['post'][img_no]['@source']
              embed.image = { url: output['posts']['post'][img_no]['@file_url'] }
              embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Warning: Some sources will be broken or NSFW')
            end
          else
            event.channel.send_embed('here you go! :u') do |embed|
              embed.title = 'View Source'
              embed.url = output['posts']['post']['@source']
              embed.image = { url: output['posts']['post']['@file_url'] }
              embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Warning: Some sources will be broken or NSFW')
            end
          end
        rescue StandardError
          event << "no posts found :(\nplease consider checking if your shipname was entered correctly\n<https://docs.google.com/spreadsheets/d/1IR5mmxNxgwAqH0_VENC0KOaTgSXE_azPts8qwqz9xMk>"
        end
        nil
      end
    end
  end
end
