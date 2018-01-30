require 'rest-client'
require 'nori'
require 'redis'

module Bot
  module Commands
    # command searches the MSPABooru and display a random result from the first
    # 25 images grabbed
    module Mspa
      extend Discordrb::Commands::CommandContainer
      command(:mspa, description: "searches and posts images from mspabooru\n usage: >mspa `any-tags-here`\ntags are split by spaces, multiple word tags are split with '-'\nkeep in mind mspabooru uses some funky search tags, here is a list of every ship name: <https://docs.google.com/spreadsheets/d/1IR5mmxNxgwAqH0_VENC0KOaTgSXE_azPts8qwqz9xMk>") do |event, *args|
        redis = Redis.new
        unless redis.exists("#{event.server.id}:mspalock")

          parser = Nori.new
          limit = 25
          pid = 0
          url = 'http://mspabooru.com//index.php?page=dapi&s=post&q=index'
          url << "&pid=#{pid}&limit=#{limit}&tags="
          puts url
          args.each do |tag|
            # consider putting a case statement here to convert common shipnames to their 'mspabooru' name
            url << "#{tag}+"
          end
          url << 'rating:safe+-*cest+-erasure+-gore+-deleteme+-vomit'

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
          redis.set "#{event.server.id}:mspalock", true
          redis.expire("#{event.server.id}:mspalock", 7)
        else
          event.send_temporary_message("please slow down!\nwait another #{redis.ttl("#{event.server.id}:mspalock")} seconds :p", redis.ttl("#{event.server.id}:mspalock"))
        end
        redis.close
      end
    end
  end
end
