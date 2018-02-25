module Bot
  module Commands
    # Command determines a pairings viability
    module Otp
      extend Discordrb::Commands::CommandContainer
      command(:otp, description: "ship some characters together!\nusage: `>otp as many characters as you want`") do |event, *args|
        if args.empty?
          event.send_message('i dont know what you want me to ship :\\')
        else

          # sanitize input
          all_args = args.join(' ')
          all_args = all_args.gsub('`', '\\\`')
          all_args = all_args.gsub('@here', '`@here`')
          all_args = all_args.gsub('@everyone', '`@everyone`')

          # math
          tally = 0

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
