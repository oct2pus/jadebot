package command

import (
	"strconv"

	"github.com/bwmarrin/discordgo"
	"github.com/oct2pus/bocto"
	"github.com/oct2pus/jadebot/search"
)

// Candy returns a page from the Homestuck Epilogues: Candy.
func Candy(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	nsfwAdventure(bot, message, input, search.CANDY)
}

// Epilogue prints a link to the Homestuck Epilogues.
func Epilogue(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	channel, err := bot.Session.Channel(message.ChannelID)
	if err == nil && channel.NSFW {
		bot.Session.ChannelMessageSend(message.ChannelID,
			"https://www.homestuck.com/epilogues")
	}
}

// Homestuck prints a page from Homestuck.
func Homestuck(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	adventure(bot, message, input, search.HS)
}

// Meat prints a page from the HomestucK Epilogues: Meat.
func Meat(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	nsfwAdventure(bot, message, input, search.MEAT)
}

// Prologue prints a page from the Homestuck Epilogues: Prologue.
func Prologue(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	nsfwAdventure(bot, message, input, search.PROLOGUE)
}

// SBAHJ prints the best conic....................
func SBAHJ(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	nsfwAdventure(bot, message, input, search.SBAHJ)
}

// adventure generates a url for an MSPA adventure.
func adventure(bot bocto.Bot,
	message *discordgo.MessageCreate, input []string, story int) {

	if len(input) > 0 {
		i, err := strconv.Atoi(input[0])
		if err == nil {
			bot.Session.ChannelMessageSend(message.ChannelID, search.Adventures[story].GetPage(i))
			return
		}
	}

	bot.Session.ChannelMessageSend(message.ChannelID, search.Adventures[story].Get())
}

// nsfwAdventure is a wrapper for adventure
// that also performs a nsfw channel check.
func nsfwAdventure(bot bocto.Bot,
	message *discordgo.MessageCreate, input []string, story int) {

	channel, err := bot.Session.Channel(message.ChannelID)
	if err == nil && channel.NSFW {
		adventure(bot, message, input, story)
	}

}
