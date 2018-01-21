# Jadebot
Jadebot is a homestuck-themed chatbot, she intends to be a fun bot for homestuck-themed discord servers.

## Features
- Can search and return articles from the mspawiki and images from the mspabooru!
- Responds to various phrases.
- Really loves you back!

### Discuss
please join us at <https://discord.gg/D3vJQQF>!

### Running it yourself

First enter the bin directory and then rename config.rb.example to config.rb, put in your Discord bot token and id in the corresonding variables. After that return to the root folder and perform `bundle install` or manually install each gem that is listed in the gemfile using `sudo gem install` Ensure you have a redis database currently running. To install Redis perform
`
sudo apt install redis-server
`
and then run
`
sudo systemctl start redis-server
`
you can then finally run
`
ruby run.rb
`
from within the root folder.

### Notice
Jadebot currently has greeter managed by "Use Voice Activity", disable Use Voice Activity to disable her greeter.
