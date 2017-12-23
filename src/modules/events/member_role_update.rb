require 'json'
require 'redis'

module Bot
    module Events
      # event stores a users roles when they change
      module MemberRoleUpdate
        extend Discordrb::EventContainer
        member_update do |event|
            if Bot::JADE.profile.on(event.server).permission?(:manage_server) && Bot::JADE.profile.on(event.server).permission?(:manage_channels)
                redis = Redis.new
                mod_log = event.server.text_channels.find { |c| c.name == 'mod-log' }
                mod_log = event.server.create_channel('mod-log') if mod_log.nil?
          
                if redis.exists("#{event.server.id}:#{event.user.id}:ROLES")
                    past_user_roles = JSON.load(redis.get("#{event.server.id}:#{event.user.id}:ROLES")).values
                    new_role_ids = []
                    remaining_roles = []
                    added_role_ids = []

                    event.roles.each_index do |index|
                        new_role_ids[index] = event.roles[index].id
                    end
                    # Check that the member still has each role we knew they had,
                    # and handle if it was removed
                    past_user_roles.each do |id|
                        if new_role_ids.include?(id)
                            remaining_roles << id    
                        else
                            #puts "Role removed: #{event.server.role(id).name}"
                            if Bot::JADE.profile.on(event.server).permission?(:send_messages, mod_log)
                                mod_log.send_embed do |embed|
                                    embed.title = "A Role Has Been Removed From A User"
                                    embed.description = "**#{event.user.username}##{event.user.tag}** has lost the **#{event.server.role(id).name}** role."
                                    embed.timestamp = Time.now
                                    embed.color = "#FEDCBA"
                                    footer_string = "Current roles: "
                                    event.user.roles.each_index do |index|
                                        footer_string << "#{event.user.roles[index].name}"
                                        if index != (event.user.roles.size - 1)
                                            footer_string << ", "
                                        end
                                    end
                                    embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: footer_string)
                                    embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{event.user.username}##{event.user.tag}", icon_url: event.user.avatar_url.to_s)
                                end
                            end
                        end
                    end

                    # Check for added roles
                    added_role_ids = new_role_ids - remaining_roles

                    added_role_ids.each do |id|
                        #puts "Role added: #{event.server.role(id).name}"
                        if Bot::JADE.profile.on(event.server).permission?(:send_messages, mod_log)
                            mod_log.send_embed do |embed|
                                embed.title = "A Role Has Been Added To A User"
                                embed.description = "**#{event.user.username}##{event.user.tag}** has gained the **#{event.server.role(id).name}** role."
                                embed.timestamp = Time.now
                                embed.color = "#ABCDEF"
                                footer_string = "Current roles: "
                                event.user.roles.each_index do |index|
                                    footer_string << "#{event.user.roles[index].name}"
                                    if index != (event.user.roles.size - 1)
                                        footer_string << ", "
                                    end
                                end
                                embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: footer_string)
                                embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{event.user.username}##{event.user.tag}", icon_url: event.user.avatar_url.to_s)
                            end
                        end
                    end
                end
                
                # Store user roles
                get_roles = {}
                event.roles.each_index do |index|
                    get_roles[index] = event.roles[index].id
                end

                redis.set "#{event.server.id}:#{event.user.id}:ROLES", "#{JSON.dump(get_roles)}"
                redis.close
                end
            end
        end
    end
end