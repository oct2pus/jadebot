# frozen_string_literal: true

module Shard
  if ARGV.length >= 2
    ID = 0
    MAX = 1
  else
    ID = ARGV[0]
    MAX = ARGV[1]
  end
end
