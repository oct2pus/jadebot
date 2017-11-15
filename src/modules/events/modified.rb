require 'json'
require 'redis'

module Bot::Events
    module Modified
        extend Discordrb::EventContainer
        message_edit() do |event|
            mod_log =  event.server.text_channels.find { |c| c.name == 'mod-log' }
            if mod_log == nil
                if Bot::JADE.profile.on(event.server).permission?(:manage_server)
                    mod_log = event.server.create_channel('mod-log')
                end
            end
            if Bot::JADE.profile.on(event.server).permission?(:send_messages, mod_log)
                redis = Redis.new
                if redis.get(event.message.id) != nil
                    original_message = JSON.parse(redis.get(event.message.id))
                    Bot::JADE.send_message(mod_log,"**#{event.user.username}##{event.user.tag}** has edited a message in **##{event.channel.name}** at #{event.timestamp}\noriginal message```#{original_message['message']}\n```new message\n```#{event.message}```")
                else
                    Bot::JADE.send_message(mod_log,"**#{event.user.username}##{event.user.tag}** has edited a message in **##{event.channel.name}** at #{event.timestamp}")
                end
            end
        end
    end
end

# module Bot::Events
#     module Deleted
#         extend Discordrb::EventContainer
#         message_delete() do |event|
#             mod_log =  event.channel.server.text_channels.find { |c| c.name == 'mod-log' }
#             if mod_log == nil
#                 if Bot::JADE.profile.on(event.server).permission?(:manage_server)
#                     mod_log = event.channel.server.create_channel("mod-log")
#                 end
#             end
#             if Bot::JADE.profile.on(event.channel.server).permission?(:send_messages, mod_log)
#                 redis = Redis.new
#                 time = Time.new
#                 if redis.get(event.id) != nil
#                      original_message = JSON.parse(redis.get(event.id))
#                     Bot::JADE.send_message(mod_log,"#{original_message["user"]} has deleted a message in **##{event.channel.name}** at #{time}, original message below```#{original_message["message"]}```")
#                 else
#                     Bot::JADE.send_message(mod_log,"a message has deleted a message in **##{event.channel.name}** at #{time}")
#                 end
#                 redis.close
#             end
#         end
#     end
# end
