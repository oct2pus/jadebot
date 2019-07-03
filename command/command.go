package command

import (
	"encoding/json"
	"encoding/xml"
	"fmt"
	"io/ioutil"
	"jadebot/search"
	"math/rand"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/bwmarrin/discordgo"
	"github.com/oct2pus/bocto"
)

// Avatar gets the first mentioned users Avatar.
func Avatar(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {
	var emb *discordgo.MessageEmbed

	// should be functionally the same if its empty or nil, if something broke
	// here assume it has to do with the nil/empty slice distinction
	if len(message.Mentions) == 0 {
		emb = bocto.ImageEmbed("Avatar",
			"",
			message.Author.AvatarURL("1024"),
			"User: "+message.Author.Username+"#"+
				message.Message.Author.Discriminator,
			bot.Color)
	} else {
		emb = bocto.ImageEmbed("Avatar", "",
			message.Message.Mentions[0].AvatarURL("1024"),
			message.Message.Mentions[0].Username+
				"#"+message.Message.Mentions[0].Discriminator,
			bot.Color)
	}
	bot.Session.ChannelMessageSendEmbed(message.ChannelID, emb)
}

// Booru searches the MSPABooru and returns the result.
func Booru(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {
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

	response, err := http.Get(url)
	if err != nil {
		bot.Session.ChannelMessageSend(message.ChannelID,
			"please don't enter gibberish to try and break me :(")
		return
	}

	data, err := ioutil.ReadAll(response.Body)
	if err != nil {
		bot.Session.ChannelMessageSend(message.ChannelID,
			"please stop trying to hurt me :(")
		return
	}

	var booruSearch search.Booru
	xml.Unmarshal(data, &booruSearch)

	if len(booruSearch.Posts) <= 0 {
		bot.Session.ChannelMessageSend(message.ChannelID,
			"no posts found :(\n"+
				"if you were trying to find a ship, make sure your shipname"+
				" was entered correctly :o\nhere is a list of all ship names"+
				" on mpsabooru: "+
				"<https://docs.google.com/spreadsheets/d/1IR5mmxNxgwAqH0_VEN"+
				"C0KOaTgSXE_azPts8qwqz9xMk>")
		return
	}

	// randomly pick a result
	rand.Seed(time.Now().UnixNano())

	randNum := rand.Intn(len(booruSearch.Posts))

	bot.Session.ChannelMessageSendEmbed(message.ChannelID,
		bocto.ImageEmbed("Source", booruSearch.Posts[randNum].Source,
			booruSearch.Posts[randNum].FileURL,
			"Warning: Some sources will be broken or NSFW", bot.Color))
}

// Credits accreditates users for their contributions.
func Credits(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {

	bot.Session.ChannelMessageSendEmbed(message.ChannelID,
		bocto.CreditsEmbed(bot.Name,
			"Chuchumi ( http://chuchumi.tumblr.com/ )",
			"sun gun#0373 ( http://taiyoooh.tumblr.com )",
			"Dzuk#1671 ( https://noct.zone/ )",
			bot.Self.AvatarURL("256"),
			bot.Color))
}

// Discord returns my discord guild.
func Discord(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {

	bot.Session.ChannelMessageSend(message.ChannelID,
		"https://discord.gg/PFCGhJQ")
}

// Dog gets a picture from dog.ceo
func Dog(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {

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

	var doge search.Dog

	response, err := http.Get(url)
	if err != nil {
		bot.Session.ChannelMessageSend(message.ChannelID,
			"something horrible went wrong when i was"+
				" searching for pups, try again")
		return
	}

	data, err := ioutil.ReadAll(response.Body)
	if err != nil {
		// TODO: Write an actual error message here
		bot.Session.ChannelMessageSend(message.ChannelID,
			"something really, really bad happened")
		return
	}

	json.Unmarshal(data, &doge)

	if doge.Status != "success" {
		bot.Session.ChannelMessageSend(message.ChannelID,
			"i could not find that breed :(\n"+
				"here is a list of breeds i can find!\n"+
				"<https://dog.ceo/dog-api/breeds-list>")
		return
	}

	bot.Session.ChannelMessageSendEmbed(message.ChannelID,
		bocto.ImageEmbed(
			"Source", doge.Message, doge.Message,
			strings.Join(input, " "), bot.Color))
}

// Doge is a joke command, it just calls Dog() with a Shiba preset.
func Doge(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {

	Dog(bot, message, []string{"shiba"})
}

// Help returns a list of commands.
func Help(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {

	bot.Session.ChannelMessageSend(message.ChannelID,
		"my commands currently are\n-`avatar`\n-`mspa`, `booru`\n"+
			"-`dog`\n-`otp`, `ship`\n-`discord`\n-`wiki`\n-`invite`\n-`help`,"+
			" `commands`, `command`\n-`help`\n-`about`, `credits`")
}

// Invite returns a bot invite.
func Invite(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {

	bot.Session.ChannelMessageSend(message.ChannelID,
		"<https://discordapp.com/oauth2/authorize?cli"+
			"ent_id=331204502277586945&scope=bot&permissions=379968>",
	)
}

// OTP returns a number, its very arbitrary but people like it.
func OTP(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {

	asString := strings.Join(input, " ")
	percent := ang(asString, 11)
	result := "I think " + asString + " has a **" + strconv.Itoa(int(percent)) +
		"/10** chance of being canon!"

	bot.Session.ChannelMessageSend(message.ChannelID, result)
}

// Wiki gets article contents and displays them in an bocto.
func Wiki(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	// gotcha with no input
	if len(input) <= 0 {
		bot.Session.ChannelMessageSend(message.ChannelID,
			"what article do you want :?")
		return
	}
	minQuality := "25"
	inputs := strings.Join(input, " ")
	// perform list
	url := "https://mspaintadventures.fandom.com/api/v1/"
	listQuery := "Search/List?query=" + inputs + "&limit=1" +
		"&minArticleQuality=" + minQuality + "&batch=1&namespaces=0%2C14"
	listData, err := getJSON(url + listQuery)
	if err != nil {
		bot.Session.ChannelMessageSend(message.ChannelID,
			"i cant seem to reach the wiki :(")
		// might also be unreadable
		return
	}
	var list search.WikiList
	json.Unmarshal(listData, &list)
	if len(list.Items) <= 0 {
		bot.Session.ChannelMessageSend(message.ChannelID,
			"i cant find that article :o")
		return
	}
	// perform "simple" (big airquotes)
	id := strconv.Itoa(list.Items[0].ID)
	simpleQuery := "Articles/AsSimpleJson?id=" + id
	simpleData, err := getJSON(url + simpleQuery)
	if err != nil {
		bot.Session.ChannelMessageSend(message.ChannelID,
			"i cant seem to reach the wiki :(")
		// might also be unreadable
		return
	}
	var simple search.WikiSimple
	json.Unmarshal(simpleData, &simple)
	if len(simple.Sections) <= 0 ||
		len(simple.Sections[0].Content) <= 0 ||
		simple.Sections[0].Content[0].Text == "" {
		// debug message
		fmt.Printf("\nsimple struct: %v\nlistQuery: %v\nsimpleQuery: %v",
			simple, url+listQuery, url+simpleQuery)
		bot.Session.ChannelMessageSend(message.ChannelID,
			"i cant read that article :?")
		return
	}
	// present bocto to user
	bot.Session.ChannelMessageSendEmbed(message.ChannelID,
		bocto.TextEmbed(list.Items[0].Title,
			"Summary",
			simple.Sections[0].Content[0].Text,
			list.Items[0].URL,
			list.Items[0].URL,
			bot.Color))
}

// ang stands for Arbitrary Number Generator
func ang(s string, m int32) int32 {
	runes := []rune(s)
	var res int32

	for _, ele := range runes {
		res += ele
	}

	return res % m
}

func getJSON(url string) ([]byte, error) {
	response, err := http.Get(url)
	if err != nil {
		return []byte{}, err
	}
	data, err := ioutil.ReadAll(response.Body)

	return data, err
}
