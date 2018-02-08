module Bot
  module Events
    # commands to run when bot joins a server
    module ServerCreate
      extend Discordrb::EventContainer
      server_create do |event|
        hash = GuildSettings.new.to_h
        $Redis.set "#{event.server.id}:SETTINGS", hash.to_json
        puts "#{event.server.name} has added jadebot!"
      end
    end
  end
end
