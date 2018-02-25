# A big thank you to z64 for the original psuedocode for this file
# todo: move this into a file
# used by GuildSettings to dynamically create attributes
class Setting
  attr_reader :name
  attr_accessor :value

  def initialize(name, default)
    @name = name
    @default = default
  end
end

# You would store a hash of these as `guild_id => GuildSettings`
# Creates a list of guild settings
class GuildSettings
  Options::OPTIONS.each do |option, attributes|
    define_method(option) do
      if instance_variable_get("@#{option}")
        instance_variable_get("@#{option}")
      else
        instance_variable_set(
          "@#{option}",
          Setting.new(option, attributes[:default])
        )
      end
    end
  end
  def to_h
    hash = {}
    Options::OPTIONS.each do |option, attributes|
      hash[option] = attributes[:default]
    end
    hash
  end
end
