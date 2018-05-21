# frozen_string_literal: true

# module Bot
#   module Commands
#     # multiple commands relating to a polling system.
#     module Poll
#       DELAY = 3
#       # class for safe vote object manipulation
#       class Vote
#         @vote
#         NUM_OF_NON_OPTIONS = 3
#         # new object creation
#         def initialize(event, title = nil)
#           @vote = Hash.new
#           if Re::DIS.exists("#{event.server.id}:#{event.channel.id}:POLL")
#             old = JSON.parse(Re::DIS.get("#{event.server.id}:#{event.channel.id}:POLL"))
#             @vote = old
#           else
#             @vote['id'] = "#{event.server.id}:#{event.channel.id}:POLL"
#             @vote['title'] = title
#             @vote['max_votes'] = -1
#             @vote['num'] = 1
#           end
#         end

#         # pushes hash into redis
#         def push()
#           Re::DIS.set(@vote['id'], @vote.to_json)
#           nil #prevent return of Re::DIS
#         end

#         # add a new option to a poll
#         def add(event, name)
#           unless name == nil?
#             p @vote
#             p @vote['num']
#             @vote["#{@vote['num']}"] = {"name": name, "votes": 0}
#             @vote['num'] += 1
#           else
#             event.send_temporary_message("whats the option you want to add :?", DELAY)
#           end
#         end

#         # removes an option from a poll
#         # TODO: failure condition
#         def remove(event, num)
#           @vote = @vote.tap { |vote| vote.delete("#{num}")}
#           @vote['num'] -= 1
#         end

#         # displays the current vote count
#         def display(event)
#           unless @vote['num'] <= 0
#             event.channel.send_embed('current poll') do |embed|
#               embed.title = @vote['title']
#               embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Max votes: #{@vote["max_votes"]}")
#               for i in 1..@vote['num']-1
#                 embed.add_field(name: @vote["#{i}"]['name'], value: @vote["#{i}"]['votes'])
#               end
#             end
#           else
#             event.send_temporary_message("poll has no options :(, add an option with `#{Pre::FIX}add option name`", DELAY)
#           end
#         end

#         # nil? returns if nil is true or not
#         def nil?()
#           if @vote.nil?
#             true
#           else
#             false
#           end
#         end

#         # ends the vote object
#         def self.end(event)
#           if Jb.i_to_b(Re::DIS.del("#{event.server.id}:#{event.channel.id}:POLL"))
#             event.send_temporary_message("poll deleted", DELAY)
#           else
#             event.send_temporary_message("no poll is going on right now!", DELAY)
#           end
#         end

#         # export returns @vote incase you want to fuck with it like a normal
#         # hash
#         def export()
#           @vote
#         end
#       end

#       extend Discordrb::Commands::CommandContainer
#       command(:poll, description: "starts or ends a poll") do |event, *args|
#         failure = "please enter `#{Pre::FIX}poll start poll name` or `#{Pre::FIX}poll end`"
#         unless args.empty?
#           if args[0] == "start"
#             if args.size >= 2
#               title = args[1..args.size].join(" ")
#               vote = Vote.new(event, title)
#               unless vote.nil?
#                 vote.push()
#                 event.send_temporary_message("Poll created!", 5)
#               end
#             end
#           elsif args[0] == "end"
#               Vote.end(event)
#           else
#             event.send_message(failure);
#           end
#         else
#             event.send_message(failure);
#         end
#       end

#       command(:add, description: "add an option to a poll") do |event, *args|
#         unless args.nil?
#           vote = Vote.new(event)
#             unless vote.nil?
#             input = Jb.sanitize(args.join(" "))
#             vote.add(event, input)
#             vote.push()
#           end
#         else
#           event.send_temporary_message("no poll is going on right now tho :?", DELAY)
#         end
#       end

#       command(:display, description: "Display poll") do |event|
#         vote = Vote.new(event)
#         unless vote.nil?
#           vote.display(event)
#         end
#       end

#     end
#   end
# end

# # Structure of a Poll Hash
# # ============================================================================#
# # {"id" => "serverid:channelid:POLL", "title"=> "poll title",
# # "max_votes" => "-1", "num" => 1, "1" => {"option name", votes},
# # "2" => {"option name", votes}, ..., "n" => {"option name", votes}}
# # ============================================================================#
# # so ["1"][] will pull up option "1" name, and ["1"][1] will bring up the vote
# # count.
