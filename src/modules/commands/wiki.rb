module Bot
  module Commands
    # Command Searches MSPA wiki and finds result
    module Wiki
      extend Discordrb::Commands::CommandContainer
      Bot::JADE.bucket :wiki_b, limit: 4, time_span: 45, delay: 7
      command(:wiki, bucket: :wiki_b, rate_limit_message: "please slow down!\nwait another %time% seconds :p", description: "searches the mspa wiki\nusage: >wiki `what you want to search`") do |event, *args|
        limit = 1
        batch = 1
        min_article_quality = 10
        search = args.join('+')
        words = Sanitize::sanitize(args.join(' '))

        base_url = 'http://mspaintadventures.wikia.com/api/v1'
        # url to be parsed
        search_url = "#{base_url}/Search/List?query=#{search}"
        search_url << "&limit=#{limit}"
        search_url << "&minArticleQuality=#{min_article_quality}"
        search_url << "&batch=#{batch}"

        event.channel.send_temporary_message("searching for #{words}", 5)

        # items is an array but will only hold one value if you set limit to
        # one
        begin
          search = JSON.parse(RestClient.get(search_url))
        rescue StandardError
          event.send_message("i couldnt find anything about \"#{words}\" :(")
        else
          id = search['items'][0]['id']
          actual_article_url = search['items'][0]['url']

          json_article_url = "#{base_url}/Articles/AsSimpleJson?id=#{id}"
          article = JSON.parse(RestClient.get(json_article_url))

          title = article['sections'][0]['title']
          text = article['sections'][0]['content'][0]['text']

          event.channel.send_embed("heres what i found about \"#{words}\" :U") do |embed|
            embed.title = title
            embed.url = actual_article_url
            embed.description = text
          end
        end
      end
    end
  end
end
