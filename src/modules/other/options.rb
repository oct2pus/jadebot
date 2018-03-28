# ##$Options###
##
# greeting_channel expects a string (a channel_id with no frills)
##
# greet expects a boolean
##
# interaction expects an int from 0 to 2 (0:no responses,1:no waifu,2: all)
##
# mspa expects an array of strings
##
###
module Options
  OPTIONS = {
    greeting_channel: {
      description: 'Configures what channel welcome messages are sent to',
      default: nil
    },
    greet: {
      description: 'Configures whether the bot posts greeting/leaving messages or not',
      default: false
    },
    interaction: {
      description: 'Configures how verbose jadebot is outside of commands ',
      default: 2
    },
    mspa: {
      description: 'Configures the default search terms blocked by jadebot',
      default: ['*cest', 'bondage', 'deleteme', 'dubcon', 'erasure', 'gore', 'mind_control', 'rating:questionable', 'undergarments', 'vomit']
    },
    greeter_message: {
      description: 'Configures the message jadebot sends when she greets someone to the server',
      default: 'hello! :D'
    },
    leaver_message: {
      description: 'Configures the message jadebot sends when she says goodbye to someone leaving the server',
      default: 'goodbye! D:'
    }
  }.freeze
end
