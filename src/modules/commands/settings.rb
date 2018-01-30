module Bot
  module Commands
    module Settings
      extend Discordrb::Commands::CommandContainer
      command(:settings, description: "Allows Admins to set bot specific settings.\nusage: >settings `option` `selection`")
    end
  end
end
