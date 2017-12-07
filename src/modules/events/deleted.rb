require 'json'
require 'redis'


module Bot
  module Events
    # event logs every time a message is deleted and displays the message that
    # was deleted in the mod-log
    module Deleted
      extend Discordrb::EventContainer
      message_delete do |event|
        if Bot::JADE.profile.on(event.channel.server).permission?(:manage_server) && Bot::JADE.profile.on(event.channel.server).permission?(:manage_channels)
          mod_log = event.channel.server.text_channels.find { |c| c.name == 'mod-log' }
          mod_log = event.channel.server.create_channel('mod-log') if mod_log.nil?
          if Bot::JADE.profile.on(event.channel.server).permission?(:send_messages, mod_log)
            redis = Redis.new
            if !redis.get(event.id).nil?
              stored_message = JSON.parse(redis.get(event.id))
              if stored_message['message'] == ''
                stored_message['message'] = 'This message was an image and nothing else'
              end
              mod_log.send_embed do |embed|
                embed.title = 'Message Deleted'
                embed.description = "A message was deleted in <##{event.channel.id}>"
                embed.timestamp = Time.now
                embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{stored_message['user']}##{stored_message['tag']}", icon_url: (stored_message['avatar']).to_s)

                embed.add_field(name: 'Deleted Message', value: (stored_message['message']).to_s)
              end
            else
              mod_log.send_embed do |embed|
                embed.title = 'Message Deleted'
                embed.description = "A message was deleted in <##{event.channel.id}>"
                embed.timestamp = Time.now
                embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: Bot::JADE.profile.username.to_s, icon_url: Bot::JADE.profile.avatar_url.to_s)

                embed.add_field(name: 'Deleted Message Not Stored', value: "Message was not found in #{Bot::JADE.profile.username}'s Database")
              end
            end
            redis.close
          end
        end
      end
    end
  end
end
