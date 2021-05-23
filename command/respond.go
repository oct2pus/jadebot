package command

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/bwmarrin/discordgo"
	"github.com/oct2pus/bocto"
	"github.com/oct2pus/jadebot/art"
	"github.com/oct2pus/jadebot/db"
)

// Confused is the respond JadeBot provides when the user inputs an incorrect command.
func Confused(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {
	respond(bot, message,
		"i don't understand, maybe you should ask for `"+bot.Prefix+"help` ;P")
}

// Mentioned is the command that activates when someone @'s JadeBot.
func Mentioned(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	respond(bot, message, "hello!\n by the way, my prefix is `"+bot.Prefix+"`! just incase you wanted to know.", art.Emoji["owo"])
}

// Reminder reminds people to not add spaces between the prefix and command.
func Reminder(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {
	if len(input) > 0 {
		output := fmt.Sprintf("please don't add a space between commands! try `%v%v` :)", bot.Prefix, strings.Join(input, " "))
		bot.Session.ChannelMessageSend(message.ChannelID, output)
	} else {
		bot.Confused(bot, message, input)
	}
}

// OwO whats this?
func OwO(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	respond(bot, message, "oh woah whats this?", art.Emoji["owo"])
}

// Love is a human emotion.
func Love(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	respond(bot, message, "i love you too."+art.Emoji["teefs"])
}

// GoodDog best friend.
func GoodDog(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	respond(bot, message, "best friend", art.Emoji["headpat"])
}

// Teef teefs.
func Teef(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	respond(bot, message, art.Emoji["teefs"])
}

// Headpat feels good. Please give headpats.
func Headpat(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	respond(bot, message, art.Emoji["headpat"])
}

// Thinking 🤔.
func Thinking(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	respond(bot, message, art.Emoji["thinking"])
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

func respond(bot bocto.Bot, message *discordgo.MessageCreate, responses ...string) {
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
		for _, response := range responses {
			bot.Session.ChannelMessageSend(message.ChannelID, response)
		}
	}
}
