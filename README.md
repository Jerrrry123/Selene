# Hello, my name is Selene (\^-^ )

I'm a gta chat bot written in lua, relying on the mod menu Stands lua API. I come with some pre-made commands, however my purpose is to make it easy to add new commands and chat triggers, and I will give you a quick guide on how to do so.

# Default commands

### /date
Sends the day/month/year in chat.

### /day
Sends the current weekday in chat.

### /time
Sends your local time in chat.

### /clear
Sends 10 messages containing "_" to make previously sent messages go away.

### /countdown <seconds\>
Starts a count down to 0 in chat as well as plays a sound every second.

### /settimer <time\><format\>
starts a timer countdown but with no messages while counting, the bot will send a message when the timer has ended. Time is a number between 1 and 60 (inclusive) and format being "min" or "sec".

### /help
Lists all existing commands in a toast.

### /crashme
Attempts to crash whoever sent the command.

### /leave
Attempts to kick whoever sent the command.

### /edition
Sends your stand edition in chat.

# config.lua

In ´store/Selene/config.lua´ you will find my saved settings as well as text commands and chat triggers, this file gets overwritten every time my settings are saved so don't write any code here. In the responses here you can use ´{user}´ as a stand in for your own name and ´{sender}´ as a stand in for the name of the message sender.

# CommandFunctions.lua

In ´store/Selene/commandFunctions.lua´ you will find commands that trigger function calls, the syntax for these are:
´cmd_funcs.COMMAND_NAME = function(msg, conf, param)end´

### msg
The msg parameter is a table containing txt, pid of the sender and tc if the message was sent in text chat.

### conf
The conf parameter is a table containing the bots current settings.

### param
The param parameter is a string that allows you to make commands that take parameters the parameter being separated from the command with a space, take /settimer for example this command takes a parameter that sets the time like ´/settimer 10min´ or ´/settimer 3sec´

#### In this functions file you can also access functions from the bot main bot file these being:


#### string addPrefix(string)
Adds the bots message prefix to the beginning of the string.

#### bool getChatToRespondIn(sent_in_team_chat, conf)
Returns a boolean of whether or not the bots response should be sent in team chat.

#### string replaceNames(string, sender_pid)
Substitutes {user} and {sender} in the string for the respective names.

#### function pairsByKeys(table)
A function for iterating over a table in the alphabetical order of the keys.


