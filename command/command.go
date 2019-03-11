package command

import (
	"Jadebot/bot"
	"Jadebot/search"
	"encoding/json"
	"encoding/xml"
	"io/ioutil"
	"math/rand"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/bwmarrin/discordgo"
)

// Avatar gets the first mentioned users Avatar.
func Avatar(bot bot.Bot,
	message *discordgo.MessageCreate,
	input []string) {
	var emb *discordgo.MessageEmbed

	// should be functionally the same if its empty or nil, if something broke
	// here assume it has to do with the nil/empty slice distinction
	if len(message.Mentions) == 0 {
		emb = imageEmbed("Avatar",
			"",
			message.Author.AvatarURL("1024"),
			"User: "+message.Author.Username+"#"+
				message.Message.Author.Discriminator,
			bot.Color,
		)
	} else {
		emb = imageEmbed("Avatar", "",
			message.Message.Mentions[0].AvatarURL("1024"),
			message.Message.Mentions[0].Username+
				"#"+message.Message.Mentions[0].Discriminator,
			bot.Color)
	}

	go messageEmbedSend(bot.Session, emb, message.ChannelID)
}

// Credits accreditates users for their contributions.
func Credits(bot bot.Bot,
	message *discordgo.MessageCreate,
	input []string) {
	go messageEmbedSend(bot.Session, creditsEmbed("Jadebot",
		"Chuchumi ( http://chuchumi.tumblr.com/ )",
		"sun gun#0373 ( http://taiyoooh.tumblr.com )",
		"Dzuk#1671 ( https://noct.zone/ )",
		bot.Color), message.ChannelID)
}

// Booru searches the MSPABooru and returns the result.
func Booru(bot bot.Bot,
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
		go messageSend(bot.Session, "please don't enter gibberish to try and"+
			" and break me :(", message.ChannelID)
	}

	data, err := ioutil.ReadAll(response.Body)
	if err != nil {
		go messageSend(bot.Session, "please stop trying to hurt me :(",
			message.ChannelID)
	}

	var booruSearch search.Booru
	xml.Unmarshal(data, &booruSearch)

	if len(booruSearch.Posts) == 0 {
		go messageSend(bot.Session, "no posts found :(\n"+
			"if you were trying to find a ship, make sure your shipname was"+
			" entered correctly :o\n here is a list of all ship names on "+
			" the booru"+
			"\n<https://docs.google.com/spreadsheets/d/1IR5mmxNxgwAqH0_VENC0"+
			"KOaTgSXE_azPts8qwqz9xMk>", message.ChannelID)
	}
	// randomly pick a result
	rand.Seed(time.Now().UnixNano())

	randNum := rand.Intn(len(booruSearch.Posts))

	go messageEmbedSend(bot.Session,
		imageEmbed("Source", booruSearch.Posts[randNum].Source,
			booruSearch.Posts[randNum].FileURL,
			"Warning: Some sources will be broken or NSFW", bot.Color),
		message.ChannelID)
}

// Dog gets a picture from dog.ceo
func Dog(bot bot.Bot,
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
		go messageSend(bot.Session, "something horrible went wrong when i was"+
			" searching for pups, try again", message.ChannelID)
	}

	data, err := ioutil.ReadAll(response.Body)
	if err != nil {
		// TODO: Write an actual error message here
		go messageSend(bot.Session, "something really, really bad happened",
			message.ChannelID)
	}

	json.Unmarshal(data, &doge)

	if doge.Status != "success" {
		go messageSend(bot.Session, "i could not find that breed :(\n"+
			"here is a list of breeds i can find!\n"+
			"<https://dog.ceo/dog-api/breeds-list>", message.ChannelID)
	}

	go messageEmbedSend(bot.Session, imageEmbed(
		"Source", doge.Message, doge.Message,
		strings.Join(input, " "), bot.Color),
		message.ChannelID)
}

// Doge is a joke command, it just calls Dog() with a Shiba preset.
func Doge(bot bot.Bot,
	message *discordgo.MessageCreate,
	input []string) {

	go Dog(bot, message, []string{"shiba"})
}

// Discord returns my discord guild.
func Discord(bot bot.Bot,
	message *discordgo.MessageCreate,
	input []string) {

	go messageSend(bot.Session, "https://discord.gg/PGVh2M8",
		message.ChannelID)
}

// Invite returns a bot invite.
func Invite(bot bot.Bot,
	message *discordgo.MessageCreate,
	input []string) {

	go messageSend(bot.Session, "<https://discordapp.com/oauth2/authorize?cli"+
		"ent_id=331204502277586945&scope=bot&permissions=379968>",
		message.ChannelID)
}

// Help returns a list of commands.
func Help(bot bot.Bot, message *discordgo.MessageCreate, input []string) {
	messageSend(bot.Session,
		"my commands currently are\n-`avatar`\n-`mspa`, `booru`\n"+
			"-`dog`\n-`otp`, `ship`\n-`discord`\n-`invite`\n-`help`,"+
			" `commands`, `command`\n-`help`\n-`about`, `credits`",
		message.ChannelID)
}

// OTP returns a number, its very arbitrary but people like it.
func OTP(bot bot.Bot,
	message *discordgo.MessageCreate,
	input []string) {

	asString := strings.Join(input, " ")
	percent := ang(asString, 11)
	result := "I think " + asString + " has a **" + strconv.Itoa(int(percent)) +
		"/10** chance of being canon!"

	go messageSend(bot.Session, result, message.ChannelID)
}

// ang stands for Arbitrary Number Generator
func ang(input string, mod int32) int32 {
	asRuneSlice := []rune(input)
	var result int32

	for _, ele := range asRuneSlice {
		result += ele
	}

	return result % mod
}

