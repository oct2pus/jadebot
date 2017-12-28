module Bot
  module Commands
    # command posts a link to the jadebot STORAGE_POLICY.md
    module Github
      extend Discordrb::Commands::CommandContainer
      command :policy do |event|
        event << '<https://github.com/oct2pus/jadebot/blob/master/STORAGE_POLICY.md>! :D'
      end
    end
  end
end
