module Bot::Commands
    module Consent
        extend Discordrb::Commands::CommandContainer
        command :consent do |event, user_input|
            filename = "src/data/@#{event.user.name}##{event.user.tag}.user"
            
            if user_input == "give"
                if !File.exist?(filename)
                    File.open(filename, 'w') do |write_file|
                        write_file << "0\n"     #exp
                        write_file << "50\n"    #to next level
                        write_file << "1"       #current level
                    end
                    event << "i will now store data on you :D" 
                else
                    event << "im already storing data on you :O"
                end
            elsif user_input == "revoke"
                if File.exist?(filename)
                    File.delete(filename)
                    event << "all information stored on you is now removed :D"
                else
                    event << "i dont seem to have you on record :?"
                end
            elsif user_input == "help"
                event << "There will be a link here"
            else 
                event << "valid inputs are `give`, `revoke` and `help`"
            end
        end
    end
end
