require 'rest-client'
require 'nori'

#searches the MSPABooru

module Bot::Commands
    module Mspa
        extend Discordrb::Commands::CommandContainer
		command :mspa do |event, *args|
			parser = Nori.new
			limit = 25
			pid = 0 
			url = "http://mspabooru.com//index.php?page=dapi&s=post&q=index&pid=#{pid}&limit=#{limit}&tags="

			args.each do |tag|
				#consider putting a case statement here to convert common shipnames to their 'mspabooru' name
				url << "#{tag}+"
			end
			url << "rating:safe+-*cest+-erasure+-deleteme"

			begin
				output = parser.parse(RestClient.get(url))

				if limit > output['posts']['@count'].to_i
					limit = (output['posts']['@count'].to_i) - 1
				end
				if limit != 0
					img_no = rand(limit)
					event.channel.send_embed("here you go! :u") do |embed|
						embed.title = 'View Source'
						embed.url = output['posts']['post'][img_no]['@source']
						embed.image = { url: output['posts']['post'][img_no]['@file_url'] }
						embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Warning: Some sources will be broken or NSFW")												
					end
				else
					event.channel.send_embed("here you go! :u") do |embed|
						embed.title = 'View Source'
						embed.url = output['posts']['post']['@source']
						embed.image = { url: output['posts']['post']['@file_url'] }
						embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Warning: Some sources will be broken or NSFW")						
						
					end
				end
			rescue Exception => exception
				event << "no posts found :(\nplease consider checking if your shipname was entered correctly\n<https://docs.google.com/spreadsheets/d/1IR5mmxNxgwAqH0_VENC0KOaTgSXE_azPts8qwqz9xMk>"
			end
						
        end
    end
end