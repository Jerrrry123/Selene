local conf = {}

conf.CASE_SENSITIVE = false
conf.CHAT_TO_RESPOND_IN = 3
conf.CHAT_TO_RESPOND_TO = 3
conf.COMMAND_PREFIX = '/'
conf.MESSAGE_HISTORY = true
conf.RESPOND_TO_FRIENDS = false
conf.RESPOND_TO_STRANGERS = false
conf.RESPOND_TO_USER = true
conf.RESPONSE_DELAY = 0
conf.RESPONSE_PREFIX = '>'
conf.RUN_ON_STARTUP = true

conf.command_list = {
  ['bot'] = 'I\'m a gta bot, Beep boop.',
  ['botname'] = 'My name is Selene',
  ['ping'] = 'Pong',
  ['reee'] = 'Retard!',
  ['sender'] = '{sender}',
  ['user'] = '{user}',
}

local cmd_funcs = require 'store//Selene//commandFunctions'

for name, func in pairs(cmd_funcs) do conf.command_list[name] = func end

conf.chat_triggers = {
  ['Kick Toxics'] = {
    active = false,
    func = true,
    matchAll = false,
    triggers = {'skill issue', 'LZZ', 'LZZZ', 'LZZZZ', 'EZ', 'EZZ', 'EZZZ', 'EZZZZ'},
  },
  ['Money Drop'] = {
    active = true,
    matchAll = true,
    responses = {'Nope', 'Money drops are detected.'},
    triggers = {'money', 'drop'},
  },
  ['Stand Promotion'] = {
    active = false,
    matchAll = true,
    responses = {'Yes, I\'m using Stand, you can find it at stand.gg'},
    triggers = {'{user}', 'modding'},
  },
}

local trig_funcs = require 'store//Selene//triggerFunctions'

for name, func in pairs(trig_funcs) do if conf.chat_triggers[name].func then conf.chat_triggers[name].func = func end end

conf.identical_spam = {
  active = false,
  messages = 5,
}

conf.fast_spam = {
  active = false,
  messages = 5,
  time = 5,
}

return conf
