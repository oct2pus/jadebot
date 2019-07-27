package main

import (
	"flag"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/oct2pus/jadebot/command"
	"github.com/oct2pus/jadebot/markov"

	"github.com/oct2pus/bocto"
)

var (
	emoji = map[string]string{
		"thinking":   "<:jbthink:601863277546569779>",
		"headpat":    "<:jbheadpat:601863276581748746>",
		"embarassed": "<:jbembarassed:601863277122813953>",
		"teefs":      "<:jbteefs:601863276833406976>",
		"owo":        "<:jbowo:601863276560777220>",
		"heart":      "💚",
	}
)

const (
	pre = "==>"
)

// initialize emoji substituions
// if you host your own bot, i'd recommend replacing them with your own.
func init() {
	emoji = make(map[string]string)
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
	// if no model.json exist, disable markov commands
	// if model.json exists but does not parse, disable markov commands
	if func() bool {
		file := "model.json"
		skip := "Skipping markov commands."
		if _, err := os.Stat(file); os.IsNotExist(err) {
			fmt.Printf("%v does not exist. %v\n", file, skip)
			return false
		}
		err := markov.Load("model.json")
		if err != nil {
			fmt.Printf("%v cannot be read. %v\n", file, skip)
			return false
		}
		if !canMakeMarkov() {
			fmt.Printf("%v is an invalid gomarkov model.json. %v\n", file, skip)
		}

		return true
	}() {
		bot.AddCommand("", command.ReminderMarkov)
		bot.AddCommand("pester", command.Markov)
		bot.AddCommand("markov", command.Markov)
	} else {
		bot.AddCommand("", command.Reminder)
	}

	return bot
}

func addPhrases(bot bocto.Bot) bocto.Bot {
	bot.AddPhrase("owo", []string{"oh woah whats this?", emoji["owo"]})
	bot.AddPhrase("love you jade", []string{"i love you too!!", emoji["teefs"] +
		emoji["heart"]})
	bot.AddPhrase("love jade", []string{"i love you too!!", emoji["teefs"] +
		emoji["heart"]})
	bot.AddPhrase("good dog", []string{"best friend", emoji["headpat"]})
	bot.AddPhrase("teef", []string{emoji["teefs"]})
	bot.AddPhrase("kissjade", []string{emoji["embarassed"] + emoji["heart"]})
	bot.AddPhrase("headpat", []string{emoji["headpat"]})
	bot.AddPhrase("*pap*", []string{emoji["headpat"]})
	bot.AddPhrase("soosh pap", []string{emoji["headpat"]})
	bot.AddPhrase("*pats*", []string{emoji["headpat"]})
	bot.AddPhrase(":think", []string{emoji["thinking"]})
	bot.AddPhrase("think:", []string{emoji["thinking"]})
	bot.AddPhrase("thinking:", []string{emoji["thinking"]})
	bot.AddPhrase("🤔", []string{emoji["thinking"]})

	return bot
}

// canMakeMarkov makes sure the markov file is valid. If no errors are reported, return true.
func canMakeMarkov() bool {
	_, err := markov.Generate(1)
	if err != nil {
		return false
	}
	return true
}
