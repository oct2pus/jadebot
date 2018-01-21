require 'rest-client'
require 'redis'
require 'json'

module Bot
  module Commands
    module Wiki
      extend Discordrb::Commands::CommandContainer
      command(:wiki, description: "searches the mspa wiki\nusage: >wiki `what you want to search`") do |event, *args|
        redis = Redis.new
        if !redis.exists("#{event.server.id}:wikilock")

          limit = 1
          batch = 1
          min_article_quality = 10
          search = args.join('+')
          words = args.join(' ')

          # url to be parsed
          search_url = "http://mspaintadventures.wikia.com/api/v1/Search/List?query=#{search}&limit=#{limit}&minArticleQuality=#{min_article_quality}&batch=#{batch}"

          event.channel.send_temporary_message("searching for #{words}", 5)

          # items is an array but will only hold one value if you set limit to one
          begin
            search = JSON.parse(RestClient.get(search_url))
          rescue StandardError
            event.send_message("I couldn't find anything about \"#{words}\" :(")
          else
            redis.set "#{event.server.id}:wikilock", true
            redis.expire("#{event.server.id}:wikilock", 7)

            id = search["items"][0]["id"]
            actual_article_url = search["items"][0]["url"]

            json_article_url = "http://mspaintadventures.wikia.com/api/v1/Articles/AsSimpleJson?id=#{id}"
            article = JSON.parse(RestClient.get(json_article_url))

            title = article["sections"][0]["title"]
            text = article["sections"][0]["content"][0]["text"]

            event.channel.send_embed("heres what i found about \"#{words}\" :U") do |embed|
              embed.title = title
              embed.url = actual_article_url
              embed.description = text
            end
          end
        else
            event.send_temporary_message("please slow down!\nwait another #{redis.ttl("#{event.server.id}:wikilock")} seconds :p", redis.ttl("#{event.server.id}:wikilock"))
        end
      end
    end
  end
end
