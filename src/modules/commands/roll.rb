# frozen_string_literal: true

module Bot
  module Commands
    # command rolls dice, needs to be input in XdXX(+-X), with X being a number
    # and (being optional)
    module Roll
      extend Discordrb::Commands::CommandContainer

      # return all rolls
      def get_roll(input)
        rolls = Array.new(input[-1])

        rolls.each_index do |roll|
          rolls[roll] = rand(input[0]) + 1
        end

         rolls
      end

      # writes the embed
      def write_embed(dice_message, input, total, rolls, die_image)

        rolls.each_index do |roll|
          output = '`'
          output += "|#{rolls[roll].to_s.center(2)}|"
          output += "\t" if roll % 4 != 4
          output += "`\n`" if roll % 4 == 4
        end
          output += '`'

        # catches edgecase that would fuck over formatting
        if output.end_with?('``')
          output.slice!((output.length - 1)...(output.length))
        end

        # output
        event.channel.send_embed do |embed|
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(icon_url: show, text: dice_message.to_s)
          embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: show)
          embed.add_field(name: 'Rolls', value: output.to_s, inline: true)
          embed.add_field(name: 'Modifier', value: "#{mod_out}#{input[1]}", inline: true)
          embed.add_field(name: 'Results', value: total.to_s, inline: true)
        end
      end


      # gets die image used in write_embed
      def get_die_image(die_size)
        die = {
          d2: 'https://raw.githubusercontent.com/oct2pus/jadebot/master/src/art/coin.png',
          d4: 'https://raw.githubusercontent.com/oct2pus/jadebot/master/src/art/d4.png',
          d6: 'https://raw.githubusercontent.com/oct2pus/jadebot/master/src/art/d6.png',
          d8: 'https://raw.githubusercontent.com/oct2pus/jadebot/master/src/art/d8.png',
          d10: 'https://raw.githubusercontent.com/oct2pus/jadebot/master/src/art/d10.png',
          d12: 'https://raw.githubusercontent.com/oct2pus/jadebot/master/src/art/d12.png',
          d20: 'https://raw.githubusercontent.com/oct2pus/jadebot/master/src/art/d20.png'
        }
        image_url = ''
        puts die_size
        image_url = case die_size
        when 13..120
          die[:d20]
        when 11..12
          die[:d12]
        when 9..10
          die[:d10]
        when 7..8
          die[:d8]
        when 5..6
          die[:d6]
        when 3..4
          die[:d4]
        else
          die[:d2]
        end

        return image_url
      end
      
      def valid_message(message, event)
        if dice_message =~ /[0-9]+d[0-9]+((\+|-)[0-9])?/
          true
        else
          event.send_message('please write that again in XXdXX format :U')
          false
      end

      command(:roll, description: "roll up to 20 dice\nusage: #{Pre::FIX}roll `NdN+-N`") do |event, dice_message|
        # process
        if valid_message(dice_message, event)
          input = dice_message.split(/(d|\+|-)/)
          input.each { |x| puts x }
          # string processing

          mod_out = '+'
          if roll_math
            total += input[1]
          else
            total -= input[1]
            mod_out = '-'
          end

          roll_math = false if input[3] == '-'

          input = input.keep_if { |a| a =~ /[0-9]/ }
          input[0] = input[0].to_i
          input[1] = input[1].to_i
          input[2] = if input.size <= 2
                       0
                     else
                       input[2].to_i
                     end

          # failure states
        end
      end
    end
  end
end
