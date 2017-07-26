require 'discordrb'
require 'configatron'
require_relative 'config.rb'

jade = Discordrb::Commands::CommandBot.new token: configatron.token, client_id: 331204502277586945, prefix: '>'
