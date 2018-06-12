#frozen_string_literal: false
# note to future me: if shit is getting weird w/ strawpoll its because i didnt
# bother to impliment rate limiting since its 100 per hour

module Bot
  module Commands
    # multiple commands relating to Strawpoll
    module Poll
      class Poll_builder
          @@title = nil
          @@options = []
          @@multi = false
        def initialize(vals, multi)

          vals.each_index do |index| 
            if index == 0
              @@title = vals[index]
            else
              @@options[index-1] = vals[index]
            end
          end
          
          @@multi = multi # true if users can vote on multiple options

        end
        def to_h
          hash = {}
          
          hash['title'] = @@title
          hash['options'] = @@options
          hash['multi'] = @@multi

          hash
        end
      end
      extend Discordrb::Commands::CommandContainer
      command(:poll, description: "starts a strawpoll\nusage: #{Pre::FIX}poll title | option 1 | option 2 | ... | option n\n returns the current poll if there is an ongoing poll\nall polls expire after 24 hours") do |event, *args|

        unless !event.user.permission? :administrator
          sArgs = args.join(" ") # args as a string
          pArgs = sArgs.split("|") # args split into new array
          if Re::DIS.exists "#{event.server.id}:#{event.channel.id}:POLL"
            event.send_message("The Current Poll is: #{Re::DIS.get "#{event.server.id}:#{event.channel.id}:POLL"}")
          else
            break if sArgs.empty? || pArgs.length <= 2
            poll = Poll_builder.new(pArgs, false).to_h.to_json

            begin
              request = RestClient.post(
                'https://strawpoll.me/api/v2/polls',
                poll,
                content_type: "application/json"
              )
              rescue RestClient::ExceptionWithResponse => err # follow 302 response
              result = JSON.parse(err.response.follow_redirection)
            end

            url = "https://strawpoll.me/#{result['id']}"
            event.send_message("here is your poll :D\n#{url}")
            Re::DIS.set "#{event.server.id}:#{event.channel.id}:POLL", url
            Re::DIS.expire "#{event.server.id}:#{event.channel.id}:POLL", 86400 # 24 hours
            nil
          end
          # todo: write fail conditions
          # if sArgs.empty? && !Re::DIS.exists("#{event.server.id}:#{event.channel.id}:POLL")
          #   event.send_temporary_message("please tell me a title and two or more options\nsee #{Pre::FIX}help poll for info", 5)
          # elsif pArgs <= 2 && !Re::DIS.exists("#{event.server.id}:#{event.channel.id}:POLL")
          #   event.send_temporary_message("i need at least two or more options\nsee #{Pre::FIX}help poll for info", 5)
          # end
        else
          event.send_temporary_message("only administrators can create polls :(", 5)
        end
      end
    end
  end
end