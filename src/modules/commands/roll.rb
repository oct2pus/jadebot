# frozen_string_literal: true

module Bot
  module Commands
    # multitude of Dice Rolling Commands
    module Roll
      extend Discordrb::Commands::CommandContainer

      # validates input
      def self.valid_message(message, event)
        validity = true
        if message =~ /[0-9]+d[0-9]+((\+|-)[0-9])?/
            # [0] is the amount of dice
            split = message.split(/(d|\+|-)/)
          if split[0].to_i > 20 || split[0].to_i < 1
            event.send_temporary_message('try and roll a number of die from 1 to 20 instead :v', 5)
            validity = false 
            # [2] is the size of the die
          elsif split[2].to_i >= 120 || split[2].to_i < 1
            event.send_temporary_message('i only have die sized from 2 to 120 :(', 5)
            validity = false 
          else
            validity = true
          end
        else
          event.send_temporary_message('please write that again in XXdXX format :U', 5)
          validity = false
        end
        
        validity
      end

      # splits input string into array
      def self.split_input(dice_message)

        # input[0] is the number of dice being rolled
        # input[1] is the type of die
        # input[2] is the size of the modifier (0 if none)
        # input[3] and above are irrelevant
        input = dice_message.split(/(d|\+|-)/)

        input = input.keep_if { |a| a =~ /[0-9]/ }

        # to_i conversions to make sure no funny business happens
        input[0] = input[0].to_i
        input[1] = input[1].to_i
        input[2] = if input.size <= 2
                      0
                    else
                      input[2].to_i
                    end

        input
      end

      # determines if the dice roll modifier is positive or negative
      # (no modifier returns positive)
      def self.get_mod_sign(dice_message)
        # default return should be true
        mod_sign = true

        # parse_message[0] is is blank
        # parse_message[1] is d
        # parse_message[2] is +/-
        # parse_message[3] and above are irrelevant
        parse_message = dice_message.split(/[0-9]+/)
 
        unless parse_message.size <= 2
          sign = parse_message[2].split('')[0]
          if sign == '-'
            mod_sign = false
          end
        end

        mod_sign
      end

      # return all rolls; input is an array
      def self.get_rolls(input)
        rolls = Array.new(input[0])

        rolls.each_index do |roll|
          rolls[roll] = rand(input[1]) + 1
        end

         rolls
      end

      # gets the total of all die rolls added together
      def self.get_total(rolls, modifier, mod_sign)
        total = 0
        rolls.each { |roll| total = total + roll}

        total = add_mod(total, modifier, mod_sign)

        total
      end

      # finds the highest or lowest die roll, adds modifier and uses that as total
      # true for highest, false for lowest
      def self.get_total_skewed(rolls, modifier, mod_sign, type)
        total = rolls[0]

        rolls.each do |roll|
          if type
            if roll > total
              total = roll
            end
          else
            if roll < total
              total = roll
            end
          end
        end

        total = add_mod(total, modifier, mod_sign)

        total
      end

      # adds the modifier to total
      def self.add_mod(total, modifier, mod_sign)
        if mod_sign
          total = total + modifier
        else
          total = total - modifier
        end

        total
      end
      
      # gets die image used in write_embed
      def self.get_die_image(die_size)
        die = {
          d2: 'https://raw.githubusercontent.com/oct2pus/jadebot/master/src/art/coin.png',
          d4: 'https://raw.githubusercontent.com/oct2pus/jadebot/master/src/art/d4.png',
          d6: 'https://raw.githubusercontent.com/oct2pus/jadebot/master/src/art/d6.png',
          d8: 'https://raw.githubusercontent.com/oct2pus/jadebot/master/src/art/d8_vriska.png',
          d10: 'https://raw.githubusercontent.com/oct2pus/jadebot/master/src/art/d10_alt.png',
          d12: 'https://raw.githubusercontent.com/oct2pus/jadebot/master/src/art/d12.png',
          d20: 'https://raw.githubusercontent.com/oct2pus/jadebot/master/src/art/d20.png'
        }
        image_url = ''
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

      # writes the embed
      def self.write_embed(dice_message, input, mod_sign, rolls, total, die_image, event)

        output = '`'
        rolls.each_index do |roll|
          output += "`\n`" if roll % 4 == 0 && roll != 0
          output += "\t" if roll == 0 || roll % 4 != 0
          output += "|#{rolls[roll].to_s.center(3)}|"
        end
          output += '`'

        # catches edgecase that would fuck over formatting
        if output.end_with?('``')
          output.slice!((output.length - 1)...(output.length))
        end

        mod_out = '+'
        unless mod_sign
          mod_out = '-'
        end

        # output
        event.channel.send_embed do |embed|
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(icon_url: die_image, text: dice_message.to_s)
          embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: die_image)
          embed.add_field(name: 'Rolls', value: output.to_s, inline: true)
          embed.add_field(name: 'Modifier', value: "#{mod_out}#{input[2]}", inline: true)
          embed.add_field(name: 'Results', value: total.to_s, inline: true)
        end
      end

      # Commands

      command(:roll, description: "roll up to 20 dice\nusage: #{Pre::FIX}roll `NdN+-N`") do |event, dice_message|
        # process
        if valid_message(dice_message, event)

          input = split_input(dice_message)
          
          mod_sign = get_mod_sign(dice_message)
          
          rolls = get_rolls(input)
          
          total = get_total(rolls, input[2], mod_sign)

          die_image = get_die_image(input[1])

          write_embed(dice_message, input, mod_sign, rolls, total, die_image, event)

        end
      end

      command(:hroll, description: "roll up to 20 dice\nonly the highest value is added to the total\nusage: #{Pre::FIX}hroll `NdN+-N`") do |event, dice_message|
        # process
        if valid_message(dice_message, event)

          input = split_input(dice_message)
          
          mod_sign = get_mod_sign(dice_message)
          
          rolls = get_rolls(input)
          
          total = get_total_skewed(rolls, input[2], mod_sign, true)

          die_image = get_die_image(input[1])
          nil

          write_embed(dice_message, input, mod_sign, rolls, total, die_image, event)
        end
      end

      command(:lroll, description: "roll up to 20 dice\nonly the lowest value is added to the total\nusage: #{Pre::FIX}lroll `NdN+-N`") do |event, dice_message|
        # process
        if valid_message(dice_message, event)

          input = split_input(dice_message)
          
          mod_sign = get_mod_sign(dice_message)
          
          rolls = get_rolls(input)
          
          total = get_total_skewed(rolls, input[2], mod_sign, false)

          die_image = get_die_image(input[1])
          nil

          write_embed(dice_message, input, mod_sign, rolls, total, die_image, event)
        end
      end

    end
  end
end