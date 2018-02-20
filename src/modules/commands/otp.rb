module Bot
  module Commands
    # command posts a link to the jadebot github page
    module Otp
      extend Discordrb::Commands::CommandContainer
      command(:otp, description: "ship some characters together!\nusage: `>otp as many characters as you want`") do |event, *args|
        if args.empty?
          event.send_message('i dont know what you want me to ship :\\')
        else

          # math
          all_args = args.join('')
          tally = 0

          all_args.split(//).each do |arg|
            tally += arg.ord
          end

          tally = (tally*2 % 100) + 1

          # display
          ush = (tally / 10).to_i # ultra simple hash - thanks tjb
          hearts = ':heart:' * percent
          unhearts = ':broken_heart:' * (10 - percent) 
          message = "id say that #{args.join(' ')} has about a #{tally}% chance of being canon! :D \n"
          message << hearts + unhearts
          event.send_message(message)
        end
      end
    end
  end
end
