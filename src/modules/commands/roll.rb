#TODO: Rewrite of code

module Bot
  module Commands
    # command rolls dice, needs to be input in XdXX(+-X), with X being a number and (being optional)
    module Roll
      extend Discordrb::Commands::CommandContainer
      command :roll do |event, dice_message|
        # to do: make a prettier output

        # vars
        eval_command = ''
        counter_message = 0
        counter_eval = 0
        roll_amount = 0
        roll_size = 0
        roll_mod = 0
        d_pass = false
        math_pass = false
        math_type = true	# determines if modifier is positive or negative
        result = {}
        result_total = 0
        result_message = 'you rolled ```'

        # process
        if dice_message =~ /[0-9]+d[0-9]+((\+|-)[0-9])?/

          # parse dice roll
          begin
            eval_command[counter_eval] = dice_message[counter_message]

            if (dice_message[counter_message + 1] == 'd') && !d_pass
              roll_amount = eval_command.to_i.abs

              eval_command = ''
              counter_eval = -1
              counter_message += 1
              d_pass = true
            end

            if dice_message[counter_message + 1] =~ /([+-])/
              math_type = false if dice_message[counter_message + 1] == '-'

              roll_size = eval_command.to_i.abs

              eval_command = ''
              counter_eval = -1
              counter_message += 1
              math_pass = true
            end

            counter_message += 1
            counter_eval += 1
          end while counter_message < dice_message.size

          if !math_pass
            roll_size = eval_command.to_i.abs

          else math_pass == true
              if !math_type
                roll_mod -= eval_command.to_i
              else
                roll_mod += eval_command.to_i
              end

          end

          if roll_amount > 100
            event << "sorry that many die will make my processor cry\nyou can only roll up to 100 die >:U"
            break
          elsif (roll_size == 0) || (roll_amount == 0)
            event << 'please dont be a smartass'
            break
          end

          i = 0
          until i >= roll_amount
            result[i] = rand(roll_size) + 1
            result_total += result[i]

            result_message << "#{result[i]} "
            i += 1
          end

          result_total += roll_mod
          result_message << "```and with a modifier of #{roll_mod} you get: #{result_total}"

          event << if result_message.size <= 1000
                    result_message
                  else
                    'woah fuckass you just passed discord message limit with that roll >:U'
                  end
        elsif dice_message.nil?
          event << 'you didnt tell me what dice you wanted to roll :o'
        else
          event << 'please use the XXdXX format, with XX being any number :D'
        end
      end
    end
  end
end
