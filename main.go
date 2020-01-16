package main

import (
	"flag"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/oct2pus/jadebot/command"
	"github.com/oct2pus/jadebot/db"
	"github.com/oct2pus/jadebot/markov"

	"github.com/oct2pus/bocto"
)

const (
	pre = "==>"
)

func main() {
	var token string
	var jade bocto.Bot
	flag.StringVar(&token, "t", "", "Bot Token")
	flag.Parse()
	// create bot
	err := jade.New("JadeBot", pre, token, 0x4bec13)
	if err != nil {
		fmt.Printf("%v can't login\nerror: %v\n", jade.Name, err)
		return
	}
	// initialize databases (if they do not exist)
	if db.InitDB() != nil {
		fmt.Printf("Cannot init database: %v\n", err)
		return
	}
	if db.CreateTable("reponses") != nil {
		fmt.Printf("Cannot create table: %v\n", err)
		return
	}
	if db.CreateTable("mspa") != nil {
		fmt.Printf("Cannot create table: %v\n", err)
		return
	}

	// add commands and responses
	jade = addCommands(jade)
	jade.Confused = command.Confused
	jade.Mentioned = command.Mentioned
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
	// emojis last, alphabetical order by emoji name
	bot.AddCommand("about", command.Credits)
	bot.AddCommand("avatar", command.Avatar)
	bot.AddCommand("booru", command.Booru)
	//	bot.AddCommand("candy", command.Candy)
	bot.AddCommand("command", command.Help)
	bot.AddCommand("commands", command.Help)
	bot.AddCommand("credits", command.Credits)
	bot.AddCommand("discord", command.Discord)
	bot.AddCommand("dog", command.Dog)
	bot.AddCommand("doge", command.Doge)
	bot.AddCommand("help", command.Help)
	//	bot.AddCommand("epilogue", command.Epilogue)
	//	bot.AddCommand("epilogues", command.Epilogue)
	//	bot.AddCommand("homestuck", command.Homestuck)
	//	bot.AddCommand("hs", command.Homestuck)
	bot.AddCommand("invite", command.Invite)
	//	bot.AddCommand("meat", command.Meat)
	bot.AddCommand("mspa", command.Booru)
	bot.AddCommand("otp", command.OTP)
	//	bot.AddCommand("prologue", command.Prologue)
	//	bot.AddCommand("sbahj", command.SBAHJ)
	bot.AddCommand("ship", command.OTP)
	bot.AddCommand("wiki", command.Wiki)
	//	bot.AddCommand("🍬", command.Candy)
	//	bot.AddCommand("🍖", command.Meat)

	// if no model.json exist, disable markov commands
	// if model.json exists but does not parse, disable markov commands
	if markovSupport() {
		bot.AddCommand("", command.ReminderMarkov)
		bot.AddCommand("pester", command.Markov)
		bot.AddCommand("markov", command.Markov)
	} else {
		bot.AddCommand("", command.Reminder)
	}

	return bot
}

/*
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
*/
// markovSupport does a runtime test to verify if the markov command will work.
// disables markov support if false
func markovSupport() bool {
	file := "model.json"
	skip := "Skipping markov commands."

	// test if file exists.
	if _, err := os.Stat(file); os.IsNotExist(err) {
		fmt.Printf("%v does not exist. %v\n", file, skip)
		return false
	}

	// test if file can be read.
	err := markov.Load(file)
	if err != nil {
		fmt.Printf("%v cannot be read. %v\n", file, skip)
		return false
	}

	// test if valid markov file.
	_, err = markov.Generate(1)
	if err != nil {
		fmt.Printf("%v is an invalid gomarkov model.json. %v\n", file, skip)
		return false
	}

	return true
}
