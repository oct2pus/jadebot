# frozen_string_literal: true

module Bot
  module Commands
    # Command determines a pairings viability
    module Otp
      extend Discordrb::Commands::CommandContainer
      command(:otp, description: "ship some characters together!\nusage: `#{Pre::FIX}otp as many characters as you want`") do |event, *args|
        if args.empty?
          event.send_message('i dont know what you want me to ship :\\')
        else

          # sanitize input
          all_args = Jb.sanitize(args.join(' '))

          # math
          tally = 0

          # why ord? it generates a semi-arbitrary number as far as the user is
          # concerned and lets me give a numeric value to a string, do not ask
          # what ord does or how it finds this number because im a dumbass and
          # don't know.
          all_args.split(//).each do |arg|
            tally += arg.ord
          end

          tally = (tally * 2 % 100) + 1

          ush = (tally / 10).to_i # ultra simple hash - thanks tjb
          hearts = ':heart:' * ush
          unhearts = ':broken_heart:' * (10 - ush)

          # display
          message = "id say that #{all_args} has about a #{tally}% chance of being canon! :D \n"
          message << hearts + unhearts
          event.send_message(message)
        end
      end
    end
  end
end
