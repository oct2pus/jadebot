package command

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/bwmarrin/discordgo"
	"github.com/oct2pus/bocto"
	"github.com/oct2pus/jadebot/db"
)

func Confused(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {
	respond(bot, message,
		"i don't understand, maybe you should ask for `"+bot.Prefix+"help` ;P")
}

// Reminder reminds people to not add spaces between the prefix and command.
func Reminder(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {
	if len(input) > 0 {
		output := fmt.Sprintf("please don't add a space between commands! try `%v%v` :)", bot.Prefix, strings.Join(input, " "))
		bot.Session.ChannelMessageSend(message.ChannelID, output)
	} else {
		bot.Session.ChannelMessageSend(message.ChannelID, bot.Confused)
	}
}

// ReminderMarkov reminds people to not add spaces between the prefix and command.
// Uses Markov instead of bot.Confused when no input is detected.
func ReminderMarkov(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {
	if len(input) > 0 {
		Reminder(bot, message, input)
	} else {
		Markov(bot, message, input)
	}
}

func respond(bot bocto.Bot, message *discordgo.MessageCreate, response string) {
	i, err := strconv.Atoi(message.GuildID)
	if err != nil {
		fmt.Printf("cannot convert guildID number, something really bad happened.\n")
		return
	}
	o, err := db.LookupEntry(i, "responses")
	if err != nil {
		return
	}
	if o == "true" || o == "" {
		bot.Session.ChannelMessageSend(message.ChannelID, response)
	}
}
