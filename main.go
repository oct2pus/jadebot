package main

import (
	"flag"
	"fmt"
	"jadebot/command"
	"os"
	"os/signal"
	"syscall"

	"bocto"
)

var (
	emoji map[string]string
)

const (
	pre = "==>"
)

// initialize emoji substituions
// if you host your own bot, i'd recommend replacing them with your own.
func init() {
	emoji["thinking"] = "<:jbthink:601863277546569779>"
	emoji["headpat"] = "<:jbheadpat:601863276581748746>"
	emoji["embarassed"] = "<:jbembarassed:601863277122813953>"
	emoji["teefs"] = "<:jbteefs:601863276833406976>"
	emoji["owo"] = "<:jbowo:601863276560777220>"
	emoji["heart"] = "💚"
}

func main() {
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
	bot.AddPhrase("owo", "oh woah whats this?", emoji["owo"])
	bot.AddPhrase("love you jade", "i love you too!!", emoji["teefs"]+
		emoji["heart"])
	bot.AddPhrase("good dog", "best friend", emoji["headpat"])
	bot.AddPhrase("teef", emoji["teefs"])
	bot.AddPhrase("kissjade", emoji["embarassed"]+emoji["heart"])
	bot.AddPhrase("headpat", emoji["headpat"])
	bot.AddPhrase("*pap*", emoji["headpat"])
	bot.AddPhrase("soosh pap", emoji["headpat"])
	bot.AddPhrase("*pats*", emoji["headpat"])
	bot.AddPhrase(":think", emoji["thinking"])
	bot.AddPhrase("think:", emoji["thinking"])
	bot.AddPhrase("thinking:", emoji["thinking"])
	bot.AddPhrase("🤔", emoji["thinking"])

	return bot
}
