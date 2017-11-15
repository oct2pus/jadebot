#Storage Policy

# What
Jadebot automatically converts all messages into a simple JSON statement and then stores that statement in a redis server. The things stored are the message you sent, your discord username, and your discord tag. I use the message ID unique to your message as the key to find that particular json statement.

# When
As soon as I start JadeBot back up.

# Where
Every place JadeBot has Read Message permission and the Redis NoSQL server is currently running.

# Why
To create a meaningful moderation log I must store message sent by users so Server admins can see any edits or post deletions a user makes. Most bots actually do this already (and probably for longer), I'm merely informing you because I feel thats my moral obligation when i intend to store data.

# Disclaimer
I cannot control any modifications anyone makes to their own personally hosted Jadebot sessions, they may store more or less information and may do whatever they want with that information and store it for however they want. But I intend to use these settings for my own personal session of jadebot (The one probably servicing you right now).

# Can you read our messages?
I could but I don't really care to, the way I currently store it I have zero ability (to my knowledge) display any message unless I have the key (which is fairly random and I doubt I'd have the ability to guess it).\n
Any implementation of "message reading" would only exist on Jadetton(who runs my personal branch of JadeBot) on the bot.jade.moe discord server for the sake of debugging.
