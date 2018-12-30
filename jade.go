package main

import (
	"encoding/json"
	"encoding/xml"
	"errors"
	"flag"
	"fmt"
	"io/ioutil"
	"math/rand"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"strings"
	"syscall"
	"time"

	"github.com/bwmarrin/discordgo"
	"github.com/oct2pus/botutil/embed"
	"github.com/oct2pus/botutil/etc"
	"github.com/oct2pus/botutil/logging"
)

// Prefix Const
const (
	prefix = "jade:"
)

// 'global' variables
var (
	// command line argument
	Token string
	self  *discordgo.User
	color int
)

// BooruSearch contains all relevant information pulled from a booru search
type BooruSearch struct {
	Posts []struct {
		FileURL string `xml:"file_url,attr"`
		Source  string `xml:"source,attr,omitempty"`
	} `xml:"post"`
}

// DogSearch contains the returned value from a dog.ceo api call
type DogSearch struct {
	Status  string `json:"status"`
	Message string `json:"message"`
}

// initalize variables
func init() {
	// command line argument
	flag.StringVar(&Token, "t", "", "Bot Token")
	flag.Parse()

	// error logging
	logging.CreateLog()

	// bot embed color
	color = 0x4bec13
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

	if logging.CheckError(err) {
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
func ready(session *discordgo.Session, discordReady *discordgo.Ready) {
	session.UpdateStatus(0, "prefix: \""+prefix+" \"")
	self = discordReady.User

	fmt.Println("Guilds: ", len(discordReady.Guilds))
}

// messageCreate determines if the bot needs to do something
func messageCreate(session *discordgo.Session,
	message *discordgo.MessageCreate) {

	messageSlice := etc.StringSlice(message.Message.Content)
	// Ignore all messages created by the bot itself
	if message.Author.Bot == true {
		return
	}

	// commands
	if messageSlice[0] == prefix && len(messageSlice) > 1 {
		switch messageSlice[1] {
		case "roll", "lroll", "hroll":
			session.ChannelMessageSend(message.ChannelID,
				"i gave vriska all my dice, you should check her out here!"+
					"<https://discordapp.com/oauth2/authorize?client_id=49"+
					"7943811700424704&scope=bot&permissions=281600>")
		case "otp", "ship":
			if len(messageSlice) > 2 {
				session.ChannelMessageSend(message.ChannelID,
					getOTP(messageSlice[2:]))
			} else {
				session.ChannelMessageSend(message.ChannelID,
					"what ship do you want me to evaluate? :?")
			}
		case "avatar":
			session.ChannelMessageSendEmbed(message.ChannelID,
				getUserAvatar(message.Message))
		case "mspa", "booru":
			mspaEmbed, err := searchBooru(messageSlice[2:])
			if err != nil {
				session.ChannelMessageSend(message.ChannelID,
					err.Error())
			} else {
				session.ChannelMessageSendEmbed(message.ChannelID,
					mspaEmbed)
			}
		case "discord":
			session.ChannelMessageSend(message.ChannelID,
				"https://discord.gg/PGVh2M8")
		case "dog":
			dogEmbed, err := searchDogs(messageSlice[2:])
			if err != nil {
				session.ChannelMessageSend(message.ChannelID,
					err.Error())
			} else {
				session.ChannelMessageSendEmbed(message.ChannelID,
					dogEmbed)
			}
		case "doge":
			dogEmbed, err := searchDogs([]string{"shiba"})
			if err != nil {
				session.ChannelMessageSend(message.ChannelID,
					err.Error())
			} else {
				session.ChannelMessageSendEmbed(message.ChannelID,
					dogEmbed)
			}
		case "invite":
			session.ChannelMessageSend(message.ChannelID,
				"<https://discordapp.com/oauth2/authorize?client_id="+
					"331204502277586945&scope=bot&permissions=379968>")
		case "commands", "command", "help":
			//TODO: This could be automated
			session.ChannelMessageSend(message.ChannelID,
				"my commands currently are\n-`avatar`\n-`mspa`, `booru`\n"+
					"-`dog`\n-`otp`, `ship`\n-`discord`\n-`invite`\n-`help`,"+
					" `commands`, `command`\n-`help`\n-`about`, `credits`")
		case "about", "credits":
			session.ChannelMessageSendEmbed(message.ChannelID,
				embed.CreditsEmbed("Jadebot",
					"Chuchumi ( http://chuchumi.tumblr.com/ )",
					"sun gun#0373 ( http://taiyoooh.tumblr.com )",
					"Dzuk#1671 ( https://noct.zone/ )",
					color))
		default:
			session.ChannelMessageSend(message.ChannelID,
				"i don't quite understand, maybe you should ask for `help` ;P")

		}
	}

	// text responses
	textResponse, shouldRespond := getTextResponse(message.Content)

	if shouldRespond {
		session.ChannelMessageSend(message.ChannelID, textResponse)
	}

	if etc.IsMentioned(message.Mentions, self) {
		session.ChannelMessageSend(message.ChannelID,
			"hello! :D\nby the way my prefix is '`jade: `'"+
				". just incase you wanted to know! :p")
	}
}

// getUserAvatar gets the mentioned used Avatar
// TODO: Remove later-y
func getUserAvatar(message *discordgo.Message) *discordgo.MessageEmbed {
	var emb *discordgo.MessageEmbed

	// should be functionally the same if its empty or nil, if something broke
	// here assume it has to do with the nil/empty slice distinction
	if len(message.Mentions) == 0 {
		emb = embed.ImageEmbed("Avatar", "", message.Author.AvatarURL("1024"),
			"User: "+message.Author.Username+"#"+message.Author.Discriminator,
			color)
	} else {
		emb = embed.ImageEmbed("Avatar", "",
			message.Mentions[0].AvatarURL("1024"), message.Mentions[0].Username+
				"#"+message.Mentions[0].Discriminator,
			color)
	}

	return emb
}

func searchBooru(input []string) (*discordgo.MessageEmbed, error) {
	// Building our search URL
	url := "http://mspabooru.com//index.php?page=dapi&s=post&q=index"
	pid := "0"    // page id, aka what page you are on, a page is 25 images
	limit := "25" // how many images to get

	url += "&pid=" + pid + "&limit=" + limit

	if len(input) > 0 {
		url += "&tags="
		for _, ele := range input {
			url += ele + "+"
		}
		url = strings.TrimSuffix(url, "+")
	}

	// hardcoded 'do not use' tags, allowing these outside of nsfw chats is
	// against ToS, remove stuff at your own peril.
	url += "+-*cest+-gore+-erasure+-vomit+-bondage+-dubcon+-mind_control+" +
		"-undergarments+-rating:questionable+-rating:explicit+-3d+-deleteme"

	// http Get request for values

	response, err := http.Get(url)
	if logging.CheckError(err) {
		return nil, errors.New("please don't enter gibberish to try and" +
			" and break me :(")
	}

	data, err2 := ioutil.ReadAll(response.Body)
	if logging.CheckError(err2) {
		return nil, errors.New("please stop trying to hurt me :(")
	}

	var booruSearch BooruSearch
	xml.Unmarshal(data, &booruSearch)

	if len(booruSearch.Posts) == 0 {
		return nil, errors.New("no posts found :(\n" +
			"if you were trying to find a ship, make sure your shipname was" +
			" entered correctly :o\n here is a list of all ship names on " +
			" the booru" +
			"\n<https://docs.google.com/spreadsheets/d/1IR5mmxNxgwAqH0_VENC0" +
			"KOaTgSXE_azPts8qwqz9xMk>")
	} else {

		// randomly pick a result
		rand.Seed(time.Now().UnixNano())

		randNum := rand.Intn(len(booruSearch.Posts))

		return embed.ImageEmbed("Source", booruSearch.Posts[randNum].Source,
			booruSearch.Posts[randNum].FileURL,
			"Warning: Some sources will be broken or NSFW", color), nil
	}
}

func searchDogs(input []string) (*discordgo.MessageEmbed, error) {

	for i, ele := range input {
		input[i] = strings.ToLower(ele)
	}

	var url string

	switch len(input) {
	case 0:
		url = "https://dog.ceo/api/breeds/image/random"
	case 1:
		url = "https://dog.ceo/api/breed/" + input[0] + "/images/random"
	default:
		url = "https://dog.ceo/api/breed/" + input[1] + "/" + input[0] +
			"/images/random"
	}

	var doge DogSearch

	response, err := http.Get(url)
	if logging.CheckError(err) {
		return nil, errors.New("something horrible went wrong when i was" +
			" searching for pups, try again")
	}

	data, err2 := ioutil.ReadAll(response.Body)
	if logging.CheckError(err2) {
		// TODO: Write an actual error message here
		return nil, errors.New("something really, really bad happened")
	}

	json.Unmarshal(data, &doge)

	if doge.Status != "success" {
		return nil, errors.New("i could not find that breed :(\n" +
			"here is a list of breeds i can find!\n" +
			"<https://dog.ceo/dog-api/breeds-list>")
	}

	return embed.ImageEmbed("Source", doge.Message, doge.Message,
		strings.Join(input, " "), color), nil

}

// rates ships based on semi-arbitrary text input
func getOTP(input []string) string {
	asString := strings.Join(input, " ")
	percent := etc.ANG(asString, 11)
	result := "I think " + asString + " has a **" + strconv.Itoa(int(percent)) +
		"/10** chance of being canon!"
	return result
}

// checks messages for contents, returns a response if it contains one
// emojis are sourced from the 'jade.moe' server
func getTextResponse(message string) (string, bool) {
	response := ""
	contentFound := false

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
		response = "<:jb_embarrassed:432756486406537217><:jade_hearts:4326851" +
			"08085129246>"
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
