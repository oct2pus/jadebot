package command

import "github.com/bwmarrin/discordgo"

func creditsEmbed(botName string, artist string, artist2 string,
	artist3 string, color int) *discordgo.MessageEmbed {

	thanks := "Avatar by " + artist + "\n"

	// this is such a hack
	if artist2 != "" {
		thanks += "Original Design by " + artist2 + "\n"
	}

	thanks += "Emojis by " + artist3

	embed := &discordgo.MessageEmbed{
		Color: color,
		Type:  "About",
		Fields: []*discordgo.MessageEmbedField{
			&discordgo.MessageEmbedField{
				Name: botName,
				Value: "Created by \\🐙\\🐙#0413" +
					" ( http://oct2pus.tumblr.com/ )\n" +
					botName + " uses the 'discordgo' library\n" +
					"( https://github.com/bwmarrin/discordgo/ )",
				Inline: false,
			},
			&discordgo.MessageEmbedField{
				Name:   "Special Thanks",
				Value:  thanks,
				Inline: false,
			},
			&discordgo.MessageEmbedField{
				Name: "Disclaimer",
				Value: botName + " uses **Mutant Standard Emoji**" +
					" ( https://mutant.tech )\n**Mutant Standard Emoji** are " +
					" licensed under CC-BY-NC-SA 4.0\n" +
					"( https://creativecommons.org/licenses/by-nc-sa/4.0/ )",
				Inline: false,
			},
		},
		Thumbnail: &discordgo.MessageEmbedThumbnail{
			URL: "https://cdn.discordapp.com/" +
				"avatars/497943811700424704/" +
				"0a71258d950394d7adb4a369ae9f3722.png?size=1024",
		},
	}

	return embed
}

func imageEmbed(title string, url string, image string,
	footer string, color int) *discordgo.MessageEmbed {

	if url == "" {
		url = image
	}

	embed := &discordgo.MessageEmbed{
		Title: title,
		Color: color,
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

func messageSend(s *discordgo.Session,
	message, channelID string) {
	s.ChannelMessageSend(channelID, message)
}

func messageEmbedSend(s *discordgo.Session,
	embed *discordgo.MessageEmbed,
	channelID string) {

	s.ChannelMessageSendEmbed(channelID, embed)
}
