package main

import (
	"flag"
	"fmt"
	"jadebot/command"
	"os"
	"os/signal"
	"syscall"

	"github.com/oct2pus/bocto"
)

const (
	pre = "==>"
)

func main() {
	// initalize variables
	var token string
	var jade bocto.Bot
	flag.StringVar(&token, "t", "", "Bot Token")
	flag.Parse()

	err := jade.New("JadeBot", pre, token,
		"hello! :D\nby the way my prefix is `"+pre+"`. just incase you"+
			" wanted to know! :p",
		"i don't understand, maybe you should ask for `"+pre+"help` ;P", 0x4bec13)
	if err != nil {
		fmt.Printf("%v can't login\nerror: %v\n", jade.Name, err)
		return
	}
	// add commandds and responses
	jade = addCommands(jade)
	jade = addPhrases(jade)
	// Event Handlers
	jade.Session.AddHandler(jade.ReadyEvent)
	jade.Session.AddHandler(jade.MessageCreate)
	// Open Bot
	err = jade.Session.Open()
	if err != nil {
		fmt.Printf("Error openning connection: %v\nDump bot info %v\n",
			err,
			jade.String())
	}
	// wait for ctrl+c to close.
	signalClose := make(chan os.Signal, 1)

	signal.Notify(signalClose,
		syscall.SIGINT,
		syscall.SIGTERM,
		os.Interrupt,
		os.Kill)
	<-signalClose

	jade.Session.Close()
}

func addCommands(bot bocto.Bot) bocto.Bot {
	// alphabetical order, shorter first
	bot.AddCommand("about", command.Credits)
	bot.AddCommand("avatar", command.Avatar)
	bot.AddCommand("booru", command.Booru)
	bot.AddCommand("command", command.Help)
	bot.AddCommand("commands", command.Help)
	bot.AddCommand("credits", command.Credits)
	bot.AddCommand("discord", command.Discord)
	bot.AddCommand("dog", command.Dog)
	bot.AddCommand("doge", command.Doge)
	bot.AddCommand("help", command.Help)
	bot.AddCommand("invite", command.Invite)
	bot.AddCommand("mspa", command.Booru)
	bot.AddCommand("otp", command.OTP)
	bot.AddCommand("ship", command.OTP)
	bot.AddCommand("wiki", command.Wiki)

	return bot
}

func addPhrases(bot bocto.Bot) bocto.Bot {
	bot.AddPhrase("owo", "oh woah whats this? :o")
	bot.AddPhrase("love you jade", "i love you too!! :D")
	bot.AddPhrase("good dog", "best friend")
	bot.AddPhrase("teef", "<:jadeteefs:317080214364618753>")
	bot.AddPhrase("kissjade", "<:jb_embarrassed:432756486406537217>"+
		"<:jade_hearts:432685108085129246>")
	bot.AddPhrase("pats", "<:jb_headpats:432962465437843466>")
	bot.AddPhrase(":think", "<:jadethinking:395982297490522122>")
	bot.AddPhrase("🤔", "<:jadethinking:395982297490522122>")

	return bot
}
