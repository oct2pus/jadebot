package main

import (
	"encoding/json"
	"encoding/xml"
	"errors"
	"flag"
	"fmt"
	"github.com/bwmarrin/discordgo"
	"io/ioutil"
	"log"
	"math/rand"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"strconv"
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

type BooruSearch struct {
	Posts []struct {
		FileURL string `xml:"file_url,attr"`
		Source  string `xml:"source,attr,omitempty"`
	} `xml:"post"`
}

type DogSearch struct {
	Status  string `json:"status"`
	Message string `json:"message"`
}

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
		case "otp", "ship":
			if len(message) > 2 {
				discordSession.ChannelMessageSend(discordMessage.ChannelID, getOTP(message[2:]))
			} else {
				discordSession.ChannelMessageSend(discordMessage.ChannelID, "what ship do you want me to evaluate? :?")
			}
		case "avatar":
			discordSession.ChannelMessageSendEmbed(discordMessage.ChannelID,
				getUserAvatar(discordMessage.Message))
		case "mspa", "booru":
			mspaEmbed, err := searchBooru(message[2:])
			if err != nil {
				discordSession.ChannelMessageSend(discordMessage.ChannelID,
					err.Error())
			} else {
				discordSession.ChannelMessageSendEmbed(discordMessage.ChannelID,
					mspaEmbed)
			}
		case "discord":
			discordSession.ChannelMessageSend(discordMessage.ChannelID,
				"https://discord.gg/PGVh2M8")
		case "dog":
			dogEmbed, err := searchDogs(message[2:])
			if err != nil {
				discordSession.ChannelMessageSend(discordMessage.ChannelID,
					err.Error())
			} else {
				discordSession.ChannelMessageSendEmbed(discordMessage.ChannelID,
					dogEmbed)
			}
		case "doge":
			dogEmbed, err := searchDogs([]string{"shiba"})
			if err != nil {
				discordSession.ChannelMessageSend(discordMessage.ChannelID,
					err.Error())
			} else {
				discordSession.ChannelMessageSendEmbed(discordMessage.ChannelID,
					dogEmbed)
			}
		case "invite":
			discordSession.ChannelMessageSend(discordMessage.ChannelID,
				"<https://discordapp.com/oauth2/authorize?client_id=331204502277586945&scope=bot&permissions=379968>")
		case "commands", "command", "help":
			discordSession.ChannelMessageSend(discordMessage.ChannelID, "my commands currently are\n-`avatar`\n-`mspa`, `booru`\n-`dog`\n-`otp`, `ship`\n-`discord`\n-`invite`\n-`help`, `commands`, `command`\n-`help`\n-`about`, `credits`")
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

	// hardcoded avoid tags for sfw channels
	// TODO: drop these in nsfw channels
	url += "+-*cest+-gore+-erasure+-vomit+-bondage+-dubcon+-mind_control+-undergarments+-rating:questionable+-rating:explicit+-3d"

	// http Get request for values

	response, err := http.Get(url)
	checkError(err)

	data, err2 := ioutil.ReadAll(response.Body)
	checkError(err2)

	var booruSearch BooruSearch
	xml.Unmarshal(data, &booruSearch)

	if len(booruSearch.Posts) == 0 {
		return nil, errors.New("no posts found :(\nplease consider checking if your shipname was entered correctly\n<https://docs.google.com/spreadsheets/d/1IR5mmxNxgwAqH0_VENC0KOaTgSXE_azPts8qwqz9xMk>")
	} else {

		// randomly pick a result
		rand.Seed(time.Now().UnixNano())

		randNum := rand.Intn(len(booruSearch.Posts))

		return imageEmbed("Source", booruSearch.Posts[randNum].Source,
			booruSearch.Posts[randNum].FileURL,
			"Warning: Some sources will be broken or NSFW"), nil
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
		url = "https://dog.ceo/api/breed/" + input[1] + "/" + input[0] + "/images/random"
	}

	var doge DogSearch

	response, err := http.Get(url)
	checkError(err)

	data, err2 := ioutil.ReadAll(response.Body)
	checkError(err2)

	json.Unmarshal(data, &doge)

	if doge.Status != "success" {
		return nil, errors.New("i could not find that breed :(\nhere is a list of breeds i can find!\n<https://dog.ceo/dog-api/breeds-list>")
	}

	return imageEmbed("Source", doge.Message, doge.Message, strings.Join(input, " ")), nil

}

//TODO: Change this so to use a fuzzy search
//TODO: Prevent jadebot from responding to her mention event
// Gets the avatar of the user or of a mentioned user
func getUserAvatar(message *discordgo.Message) *discordgo.MessageEmbed {
	var embed *discordgo.MessageEmbed

	// should be functionally the same if its empty or nil, if something broke
	// here assume it has to do with the nil/empty slice distinction
	if len(message.Mentions) == 0 {
		embed = imageEmbed("Avatar", "", message.Author.AvatarURL("1024"),
			"User: "+message.Author.Username+"#"+message.Author.Discriminator)
	} else {
		embed = imageEmbed("Avatar", "", message.Mentions[0].AvatarURL("1024"),
			message.Mentions[0].Username+"#"+message.Mentions[0].Discriminator)
	}

	return embed
}

// wrapper to create a very simple type of embed
// url equals image if left ""
func imageEmbed(title string, url string, image string,
	footer string) *discordgo.MessageEmbed {

	if url == "" {
		url = image
	}

	embed := &discordgo.MessageEmbed{
		Title: title,
		URL:   url,
		Image: &discordgo.MessageEmbedImage{
			URL: image,
		},
		Footer: &discordgo.MessageEmbedFooter{
			Text: footer,
		},
	}
	return embed
}

// rates ships based on semi-arbitrary text input
func getOTP(input []string) string {
	asString := strings.Join(input, " ")
	percent := arbitraryNumberGenerator(asString, 11)
	result := "I think " + asString + " has a **" + strconv.Itoa(int(percent)) + "/10** chance of being canon!"
	return result
}

// used in getOTP to get a value from 0 to 100, turned into a multipurpose
// function because why not?
func arbitraryNumberGenerator(input string, mod int32) int32 {
	asRuneSlice := []rune(input)
	var result int32

	for _, ele := range asRuneSlice {
		result += ele
	}

	return result % mod
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
				Value:  "Avatar By Chuchumi ( http://chuchumi.tumblr.com/ )\nOriginal Avatar by sun gun#0373 ( http://taiyoooh.tumblr.com )\nEmojis by Dzuk#1671 ( https://noct.zone/ )",
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
