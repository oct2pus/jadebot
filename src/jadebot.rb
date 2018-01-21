require 'discordrb'
require 'configatron'
require_relative 'bin/config'

# This is the heart of Jadebot, initalizes all other modules
module Bot
  Dir['src/modules/*.rb'].each { |mod| load mod }

  JADE = Discordrb::Commands::CommandBot.new token: configatron.token, client_id: configatron.id, prefix: '>', ignore_bots: true
  #
  # The below documentation and code chunk is from stolen from 'gemstone' which is a reference bot that inspires jadebot's structure
  #
  # This class method wraps the module lazy-loading process of discordrb command
  # and event modules. Any module name passed to this method will have its child
  # constants iterated over and passed to `Discordrb::Commands::CommandBot#include!`
  # Any module name passed to this method *must*:
  #   - extend Discordrb::EventContainer
  #   - extend Discordrb::Commands::CommandContainer
  # @param klass [Symbol, #to_sym] the name of the module
  # @param path [String] the path underneath `src/modules/` to load files from
  def self.load_modules(klass, path)
    new_module = Module.new
    const_set(klass.to_sym, new_module)
    Dir["src/modules/#{path}/*.rb"].each { |file| load file }
    new_module.constants.each do |mod|
      JADE.include! new_module.const_get(mod)
    end
  end

  load_modules(:Responses, 'responses') # these modules are silly messages jade responds with when a certain word or emoji is posted
  load_modules(:Commands, 'commands') # these modules are her ">" commands
  load_modules(:Events, 'events') # these modules are largely used for mod logging
  JADE.run
end
