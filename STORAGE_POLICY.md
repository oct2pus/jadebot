#Storage Policy

# What
Jadebot stores the following information on you if Jadebot has `manage-server` and `manage-channels` permissions.
- messages you send (for a little more than 42 hours)
- your roles on each server jadebot shares with you (stored by server)
- your display name on each server jadebot shares with you (stored by server)
- your discord username (the one you use to log in with and your default name on each server)
- your discord tag (the 4 digit number after your username)

# Why
To create a meaningful moderation log I must store message sent by users so Server admins can see any edits or post deletions a user makes. Most bots actually do this already (and probably for longer), I'm merely informing you because I feel thats my moral obligation when i intend to store data.

# Disclaimer
I cannot control any modifications anyone makes to their own personally hosted Jadebot sessions, they may store more or less information and may do whatever they want with that information and store it for however they want. But I intend to use these settings for my own personal session of jadebot (The one probably servicing you right now).

# Can you read our messages?
I could but I don't really care to, the way I currently store it I have zero ability (to my knowledge) to display any message unless I have the key (which is fairly random and I doubt I'd have the ability to guess it).
Any implementation of "message reading" would only exist on Jadetton(who runs my personal branch of JadeBot) on the bot.jade.moe discord server for the sake of debugging.
