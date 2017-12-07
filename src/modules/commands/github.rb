module Bot
  module Commands
    # command posts a link to the jadebot github page
    module Github
      extend Discordrb::Commands::CommandContainer
      command :github do |event|
        event << 'feel free to contribute to my codebase at <https://github.com/oct2pus/jadebot>! :D'
      end
    end
  end
end
