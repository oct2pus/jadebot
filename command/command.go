package command

import (
	"encoding/json"
	"encoding/xml"
	"io/ioutil"
	"math/rand"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/oct2pus/jadebot/markov"
	"github.com/oct2pus/jadebot/search"

	"github.com/oct2pus/bocto"

	"github.com/bwmarrin/discordgo"
)

/*bot.AddPhrase("owo", []string{"oh woah whats this?", emoji["owo"]})
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
*/

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
	uri := "http://mspabooru.com//index.php?page=dapi&s=post&q=index"
	pid := "0"    // page id, aka what page you are on, a page is 25 images
	limit := "25" // how many images to get

	uri += "&pid=" + pid + "&limit=" + limit

	if len(input) > 0 {
		uri += "&tags="
		for _, ele := range input {
			uri += url.QueryEscape(ele) + "+"
		}
		uri = strings.TrimSuffix(uri, "+")
	}

	// hardcoded 'do not use' tags, when outside a nsfw chat many of these
	// tags include art that would break the ToS;
	// remove stuff at your own peril.
	uri += "+-gore+-vomit+-bondage+-dubcon+-mind_control+-swimsuit+-blood" +
		"+-undergarments+-biting+-rating:questionable+-rating:explicit" +
		"+-nsfwsource+-deleteme"

	// hardcoded 'do not want' tags, these are personal judgments by me.
	uri += "+-*cest+-erasure+-3d"

	response, err := http.Get(uri)
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
		bocto.CreditsEmbed(
			bot.Name,
			bot.Self.AvatarURL("1024"),
			bot.Color,
			false,
			bocto.Contributor{
				Name:    "\\🐙\\🐙",
				URL:     "https://oct2pus.tumblr.com/",
				Message: "**Developed** by %v (%v)",
				Type:    "Developer",
			},
			bocto.Contributor{
				Name:    "Discordgo",
				URL:     "https://github.com/bwmarrin/discordgo/",
				Message: "**JadeBot** uses the **%v** library (%v)",
				Type:    "Library",
			},
			bocto.Contributor{
				Name:    "Metalhiro",
				URL:     "https://www.instagram.com/themetalhiro/?hl=en/",
				Message: "**Avatar & Emoji** by **%v** (%v)",
				Type:    "Artist",
			},
		),
	)
}

// Discord returns my discord guild.
func Discord(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {

	bot.Session.ChannelMessageSend(message.ChannelID,
		"https://discord.gg/PFCGhJQ")
}

// Dog gets a picture from dog.ceo.
func Dog(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {

	for i, ele := range input {
		input[i] = strings.ToLower(ele)
	}

	var uri string

	switch len(input) {
	case 0:
		uri = "https://dog.ceo/api/breeds/image/random"
	case 1:
		uri = "https://dog.ceo/api/breed/" + url.QueryEscape(input[0]) + "/images/random"
	default:
		uri = "https://dog.ceo/api/breed/" + url.QueryEscape(input[1]) + "/" + url.QueryEscape(input[0]) +
			"/images/random"
	}

	var doge search.Dog

	response, err := http.Get(uri)
	if err != nil {
		bot.Session.ChannelMessageSend(message.ChannelID,
			"something horrible went wrong when i was"+
				" searching for pups, please try again")
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
func Doge(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {

	Dog(bot, message, []string{"shiba"})
}

// Help returns a link to docs.jade.moe
func Help(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	bot.Session.ChannelMessageSend(message.ChannelID,
		"you should check out https://docs.jade.moe to find out "+
			"about my commands! :B")
}

// Invite prints a bot invite.
func Invite(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {

	bot.Session.ChannelMessageSend(message.ChannelID,
		"<https://discordapp.com/oauth2/authorize?cli"+
			"ent_id=331204502277586945&scope=bot&permissions=379968>",
	)
}

// Markov prints a markov chain.
func Markov(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	randSeed := time.Now().UnixNano()

	output, err := markov.Generate(randSeed)
	if err != nil {
		return
	}
	bot.Session.ChannelMessageSend(message.ChannelID, output)
}

// OTP prints a number, its very arbitrary but people like it.
func OTP(bot bocto.Bot,
	message *discordgo.MessageCreate,
	input []string) {
	if len(input) > 0 {
		asString := strings.Join(input, " ")
		percent := ang(asString, 11)
		result := "i think " + asString + " has a **" + strconv.Itoa(int(percent)) +
			"/10** chance of being canon!"
		switch percent {
		case 0, 1:
			result += " >:("
		case 2, 3:
			result += " :("
		case 4, 5, 6:
			result += " :B"
		case 7, 8:
			result += " :)"
		case 9, 10:
			result += " :D"
		}
		bot.Session.ChannelMessageSend(message.ChannelID, result)
	} else {
		bot.Session.ChannelMessageSend(message.ChannelID, "what ship do you want me to rate :?")
	}
}

// Wiki gets article contents and displays them in an embed.
func Wiki(bot bocto.Bot, message *discordgo.MessageCreate, input []string) {
	inputs := ""
	// gotcha with no input
	if len(input) <= 0 {
		bot.Session.ChannelMessageSend(message.ChannelID,
			"what article do you want :?")
		return
	}
	minQuality := "25"
	// escape user input.

	for _, ele := range input {
		inputs += url.QueryEscape(ele) + "_"
	}

	// perform list
	uri := "https://mspaintadventures.fandom.com/api/v1/"
	listQuery := "Search/List?query=" + inputs + "&limit=1" +
		"&minArticleQuality=" + minQuality + "&batch=1&namespaces=0%2C14"
	listData, err := getJSON(uri + listQuery)
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
	// perform "simple" (big airquotes) json lookup
	id := strconv.Itoa(list.Items[0].ID)
	simpleQuery := "Articles/AsSimpleJson?id=" + id
	simpleData, err := getJSON(uri + simpleQuery)
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
