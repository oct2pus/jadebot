#frozen_string_literal: false

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
          
          @@multi = multi

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
      command(:poll, description: "starts a strawpoll") do |event, *args|
        sArgs = args.join(" ") #args as String
        pArgs = sArgs.split("|") #args processed
        event.send_message(Poll_builder.new(pArgs, false).to_h)
        nil
      end
    end
  end
end