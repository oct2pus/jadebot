# frozen_string_literal: true

# This is the heart of Jadebot, initalizes all other modules
module Bot
  puts '===loading non-discordrb modules==='

  # This **MUST** load first
  Dir['src/modules/other/*.rb'].each do |mod|
    load mod
    puts "loaded #{mod}"
  end
  # These modules are misc. modules, but contain program critical classes and
  # variables

  JADE = Discordrb::Commands::CommandBot.new(
    token: configatron.token,
    client_id: configatron.id,
    shard_id: Shard::ID,    # must be less than Shard::MAX
    num_shards: Shard::MAX, # its okay if it shows less than the number you
    # entered
    prefix: Pre::FIX,       # configured in 'src/modules/other/prefix.rb'
    ignore_bots: true,      # change these
    parse_self: false       # at ones own peril
  )

  # The below documentation is from stolen from 'z64/gemstone' on github
  # which is a reference bot skeleton that inspired jadebot's structure, i've
  # slightly modified it but otherwise core documentation is the same
  #
  # This class method wraps the module lazy-loading process of discordrb
  # command and event modules. Any module name passed to this method will have
  # its child constants iterated over and passed to
  # `Discordrb::Commands::CommandBot#include!`. Any module name passed to this
  # method *must*:
  #   - extend Discordrb::EventContainer
  #   - extend Discordrb::Commands::CommandContainer
  # @param klass [Symbol, #to_sym] the name of the module
  # @param path [String] the path underneath `src/modules/` to load files from

  puts '===loading discordrb modules==='
  def self.load_modules(klass, path)
    new_module = Module.new
    const_set(klass.to_sym, new_module)
    Dir["src/modules/#{path}/*.rb"].each do |file|
      load file
      puts "loaded #{file}"
    end
    new_module.constants.each do |mod|
      JADE.include! new_module.const_get(mod)
    end
  end

  load_modules(:Responses, 'responses') # these modules are silly messages jade
  # responds with when a certain word or
  # emoji is posted
  load_modules(:Commands, 'commands') # these modules are her ">" commands
  load_modules(:Events, 'events') # these modules are for event's that are not
  # caused by direct user input
  JADE.run
end
