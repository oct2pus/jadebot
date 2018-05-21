# frozen_string_literal: true

# enter "ruby run.rb" to run jadebot
require 'ruby_cowsay'
require 'fortune_gem'
require 'rest-client'
require 'nori'
require 'redis'
require 'json'
require 'discordrb'
require 'configatron'
require 'fuzzy_match'
require_relative 'src/bin/config'

require_relative 'src/jadebot'
