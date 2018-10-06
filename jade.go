package main

import (
	"flag"
	"fmt"
	"github.com/bwmarrin/discordgo"
	"log"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"
	"time"
)

// Prefix Const
const (
	prefix = "jade:"
)

// 'global' variables
var (
	// command line argument
	Token string
	// error logging
	Log         *log.Logger
	currentTime string
	self        *discordgo.User
)

// initalize variables
func init() {
	executable, e := os.Executable()
	if e != nil {
		panic(e)
	}
	path := filepath.Dir(executable)

	// command line argument
	flag.StringVar(&Token, "t", "", "Bot Token")
	flag.Parse()
	// error logging
	currentTime = time.Now().Format("2006-01-02@15h04m")
	file, err := os.Create(path + ".logs@" + currentTime + ".log")
	if err != nil {
		panic(err)
	}
	Log = log.New(file, "", log.Ldate|log.Ltime|log.Llongfile|log.LUTC)
}

// Main
func main() {

	// Create a new Discord session using the provided bot token.
	// token must be prefaced with "Bot "
	bot, err := discordgo.New("Bot " + Token)
	if err != nil {
		fmt.Println("error creating Discord session,", err)
		return
	}

	// Bot Event Handlers
	bot.AddHandler(messageCreate)
	bot.AddHandler(ready)

	// Open a websocket connection to Discord and begin listening.
	err = bot.Open()

	if err != nil {
		fmt.Println("error opening connection,", err)
		Log.Println("error opening connection,", err)
		return
	}

	// Wait here until CTRL-C or other term signal is received.
	fmt.Println("Bot is now running.  Press CTRL-C to exit.")
	sc := make(chan os.Signal, 1)
	signal.Notify(sc, syscall.SIGINT, syscall.SIGTERM, os.Interrupt, os.Kill)
	<-sc

	// Cleanly close down the Discord session.
	bot.Close()
}

// This function is called when the bot connects to discord
func ready(discordSession *discordgo.Session, discordReady *discordgo.Ready) {
	discordSession.UpdateStatus(0, "prefix: \""+prefix+" \"")
	self = discordReady.User

	fmt.Println("Guilds: ", len(discordReady.Guilds))
}

// This function will be called (due to AddHandler above) every time a new
// message is created on any channel that the autenticated bot has access to.
func messageCreate(discordSession *discordgo.Session,
	discordMessage *discordgo.MessageCreate) {

	message := parseText(discordMessage.Message.Content)
	// Ignore all messages created by the bot itself
	if discordMessage.Author.Bot == true {
		return
	}

	// commands
	if message[0] == prefix && len(message) > 1 {
		switch message[1] {
		case "roll", "lroll", "hroll":
			discordSession.ChannelMessageSend(discordMessage.ChannelID,
				"i gave vriska all my dice, you should check her out here! <https://discordapp.com/oauth2/authorize?client_id=497943811700424704&scope=bot&permissions=281600>")
		case "discord":
			discordSession.ChannelMessageSend(discordMessage.ChannelID,
				"https://discord.gg/PGVh2M8")
		case "invite":
			discordSession.ChannelMessageSend(discordMessage.ChannelID,
				"<https://discordapp.com/oauth2/authorize?client_id=331204502277586945&scope=bot&permissions=379968>")
		case "help", "commands":
			discordSession.ChannelMessageSend(discordMessage.ChannelID,
				"im in the middle of being rewriten because of an issue involving the bot library i was previously using, which is why i was offline until now! Please give me a moment while I reassemble myself. <:jb_teefs:469677925336219649>, i could also use some input on what you want first! you should check my `discord` and tell me there!")
		case "about", "credits":
			discordSession.ChannelMessageSendEmbed(discordMessage.ChannelID, getCredits())
		default:
			discordSession.ChannelMessageSend(discordMessage.ChannelID,
				"i don't quite understand, maybe you should ask for `help` ;P")

		}
	}

	// text responses
	textResponse, shouldRespond := getTextResponse(discordMessage.Content)

	if shouldRespond {
		discordSession.ChannelMessageSend(discordMessage.ChannelID, textResponse)
	}

	if isMentioned(discordMessage.Mentions) {
		discordSession.ChannelMessageSend(discordMessage.ChannelID,
			"hello! :D\nby the way my prefix is '`jade: `'. just incase you wanted to know! :p")
	}
}

// checks messages for contents, returns a response if it contains one
// emojis are sourced from the 'jade.moe' server
func getTextResponse(message string) (string, bool) {
	response := ""
	contentFound := false
	// problem with current method, multiple responses are not created if there are multiple matches
	// sure looks a hell of a lot cleaner than a lot of if statements though
	switch {
	case strings.Contains(message, "owo"):
		response = "oh woah whats this? :o"
		contentFound = true
	case strings.Contains(message, "love you jade"):
		response = "i love you too!! :D"
		contentFound = true
	case strings.Contains(message, "good dog"):
		response = "best friend!"
		contentFound = true
	case strings.Contains(message, "teef"):
		response = "<:jadeteefs:317080214364618753>"
		contentFound = true
	case strings.Contains(message, "kissjade"):
		response = "<:jb_embarrassed:432756486406537217><:jade_hearts:432685108085129246>"
		contentFound = true
	case strings.Contains(message, "pats"):
		response = "<:jb_headpats:432962465437843466>"
		contentFound = true
	case strings.Contains(message, ":think"), strings.Contains(message, "🤔"):
		response = "<:jadethinking:395982297490522122>"
		contentFound = true
	}

	return response, contentFound
}

func isMentioned(users []*discordgo.User) bool {
	for _, ele := range users {
		if ele.Username == self.Username {
			return true
		}
	}
	return false
}

func getCredits() *discordgo.MessageEmbed {
	embed := &discordgo.MessageEmbed{
		Color: 0x4bec13,
		Type:  "About",
		Fields: []*discordgo.MessageEmbedField{
			&discordgo.MessageEmbedField{
				Name:   "Jadebot",
				Value:  "Created by \\🐙\\🐙#0413 ( http://oct2pus.tumblr.com/ )\nJadebot uses the 'discordgo' library\n( https://github.com/bwmarrin/discordgo/ )",
				Inline: false,
			},
			&discordgo.MessageEmbedField{
				Name:   "Special Thanks",
				Value:  "Avatar By Chuchumi ( http://chuchumi.tumblr.com/ )\nOriginal Avatar by sun gun#0373 ( http://taiyoooh.tumblr.com )\nEmojis by Dzuk#1671",
				Inline: false,
			},
			&discordgo.MessageEmbedField{
				Name:   "Disclaimer",
				Value:  "Jadebot uses **Mutant Standard Emoji** (https://mutant.tech)\n**Mutant Standard Emoji** are licensed under CC-BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/) ",
				Inline: false,
			},
		},
		Thumbnail: &discordgo.MessageEmbedThumbnail{
			URL: self.AvatarURL(""),
		},
	}

	return embed
}

// logs errors
func checkError(err error) bool {
	if err != nil {
		fmt.Println("error: ", err)
		Log.Println("error: ", err)
		return true
	}
	return false
}

// converts text to lowercase substrings
func parseText(m string) []string {

	m = strings.ToLower(m)
	return strings.Split(m, " ")
}
