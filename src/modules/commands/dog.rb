module Bot
  module Commands
    # module lets users post pics of dogs
    module Dog
      extend Discordrb::Commands::CommandContainer
      Bot::JADE.bucket :dogs_b, limit: 3, time_span: 20, delay: 5
      command(:dog, bucket: :dogs_b, rate_limit_message: 'give me %time% seconds to find more puppers! D:', description: "post a random cute pupper!\nusage:\n`>dog breeds` to get a list of breeds\n`>dog` to post a random dog\n`>dog breed name` to post a dog by specific breed") do |event, *breed|
        if breed[0] == 'breed' || breed[0] == 'breeds'
          url = '<https://dog.ceo/dog-api/#breeds-list>'
          event.send_message("you can see a list of breeds here: #{url}")
        elsif !breed.empty? && breed.length < 2
          url = "https://dog.ceo/api/breed/#{breed[0]}/images/random"
          Dog.get_dog(url, event)
        elsif !breed.empty?
          url = "https://dog.ceo/api/breed/#{breed[1]}/#{breed[0]}/images/random"
          Dog.get_dog(url, event)
        else # yes its supposed to be breeds/image, blame dog.ceo for varying
          # their api call names
          url = 'https://dog.ceo/api/breeds/image/random'
          Dog.get_dog(url, event)
        end
      end
      command(:doge, bucket: :dogs_b, rate_limit_message: 'give me %time% seconds to find more puppers! D:', description: "doge!\nusage: `>doge`") do |event|
        url = 'https://dog.ceo/api/breed/shiba/images/random'
        Dog.get_dog(url, event)
      end

      def self.get_dog(url, event)
        result = JSON.parse(RestClient.get(url))
        event.channel.send_embed('heres your doge') do |embed|
          embed.title = 'View Source'
          embed.url = result['message']
          embed.image = { url: result['message'] }
        end
      rescue StandardError
        event.send_message('i cant find that breed :(')
      end
    end
  end
end
