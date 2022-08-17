# Hello, my name is Selene (\^-^ )

I'm a gta chat bot written in lua, relying on the mod menu Stands lua API. I come with some pre-made commands. My purpose is to make it easy to add new commands and chat triggers. I will give you a quick guide on how to do so, however I can also come with spam reactions. To kick players who spam too many identical messages or send too many messages in a short amount of time.


# Installation

Copy or move the files to their corresponding location, `Selene.lua` should be directly in the lua scripts, while the contents of the store folder should be moved its counterpart in your lua scripts directory.

# Default commands

### /bot
Sends `I'm a gta bot, Beep boop.`

### /ping
Sends `Pong`

### /reee
Sends `Retard!`

### /sender
Sends message senders name.

### /user
Sends your name.

### /botname
Sends `My name is Selene`

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

# Default chat triggers

### Money drop
A message containing `money` and `drop` triggers the bot to respond with `Nope` or `Money drops are detected.`

### Kick Toxics
Checks if a message contains any toxic word in the list and attempts to kick the sender if it does.

### Stand Promotion
Checks if a message contains your name and `modding`, if it does the bot responds with `Yes, I\'m using Stand, you can find it at stand.gg`


# config.lua

In `store/Selene/config.lua` you will find my saved settings as well as text commands and chat triggers, this file gets overwritten every time my settings are saved so don't write any code here. In the responses here you can use `{user}` as a stand in for your own name and `{sender}` as a stand in for the name of the message sender.

# commandFunctions.lua

In `store/Selene/commandFunctions.lua` you will find commands that trigger function calls. Any string returned from a function like this will result in it being sent by the bot. The usage of these functions look like:

```lua
cmd_funcs.COMMAND_NAME = function(msg, conf, params)
    return 'Chat Response'
end
```

# triggerFunctions.lua

In `store/Selene/triggerFunctions.lua` you will find functoins that get triggered when the bot finds certain words in a message. Any string returned from a function like this will result in it being sent by the bot. The usage of these functions look like:

```lua
cmd_funcs.NAME_USED_IN_OPTION = function(msg, conf)
    return 'Chat Response'
end
```

Chat trigger functions also require a special entry in the `chat_triggers` table in `config.lua` in order to work. This should look something like this:

```lua
  ['NAME_USED_IN_OPTION'] = {
    active = <bool>,
    func = true,
    matchAll = <bool>,
    triggers = {<trigger strings>},
  },
```

# parameters

### msg
The msg parameter is a table containing: txt, pid of the sender and tc, a boolean indicating if the message was sent in text chat or not.

### conf
The conf parameter is a table containing the bots current settings.

### params
The params parameter is only passed to command functions and is a table that contains strings, that are seperated by spaces. This allows you to make commands that take parameters, take /settimer for example this command takes a parameter that sets the time like ´/settimer 10min´ or ´/settimer 3sec´, the parameter that would be passed in this case would be as follows:

```lua
{
  '3sec'
}
```

# Global functions

In this functions file you can also access functions from the bot main bot file these being:


### string addPrefix(string)
Adds the bots message prefix to the beginning of the string, then returns the result.

### bool getChatToRespondIn(sent_in_team_chat)
Returns a boolean of whether or not the bots response should be sent in team chat.

### string replaceNames(string, sender_pid)
Substitutes {user} and {sender} in the string for the respective names.

### function pairsByKeys(table)
A function for iterating over a table in the alphabetical order of the keys.

### bool is_player_friend(pid)
Checks if a player is your friend.
