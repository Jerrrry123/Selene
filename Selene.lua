util.require_natives(1651208000)

local conf = require 'store//Selene//config'

-----------------------
-- Menu options
-----------------------

function pairsByKeys(t, f)
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
  table.sort(a, f)
  local i = 0
  local iter = function()
    i += 1
    if a[i] == nil then return nil
    else return a[i], t[a[i]]
    end
  end
  return iter
end

local my_root = menu.my_root()

-----------------------
-- Bot settings
-----------------------

local bot_settings = menu.list(my_root, 'Bot Settings', {}, '')

local typeTable
local function valueToFile(value)
  local func = typeTable[type(value)]
  return func(value)
end

typeTable = {
  ['boolean'] = function(value)
    return tostring(value)
  end,
  ['number'] = function(value)
    return value
  end,
  ['table'] = function(value)
    local values = ''
    for _, v in pairsByKeys(value) do
      values = values .. valueToFile(v) ..', '
    end
    return '{'.. string.sub(values, 0, #values -2) ..'}'
  end,
  ['string'] = function(value)
    return '\''.. string.gsub(value, "'", "\\'") ..'\''
  end,
  ['function'] = function(value)
    return 'true'
  end,
}

menu.action(bot_settings, 'Save Config', {'saveBotConfig'}, 'Saves your current bot settings, text commands and chat triggers.', function()
  local config = io.open(filesystem.store_dir() .. 'Selene//config.lua', 'w')

  if config == nil then util.toast('Failed saving') return end

  config:write('local conf = {}\n\n')
  for k, v in pairsByKeys(conf) do
    if type(v) != 'table' then
      config:write('conf.'.. k ..' = '.. valueToFile(v) ..'\n')
    end
  end

  config:write('\nconf.command_list = {\n')
  for k, v in pairsByKeys(conf.command_list) do
    if type(v) != 'function' then
      config:write('  [\''.. k ..'\'] = '.. valueToFile(v) ..',\n')
    end
  end
  config:write('}\n')

  config:write('\nlocal cmd_funcs = require \'store//Selene//commandFunctions\'\n')

  config:write('\nfor name, func in pairs(cmd_funcs) do conf.command_list[name] = func end\n')

  config:write('\nconf.chat_triggers = {\n')
  for k, v in pairsByKeys(conf.chat_triggers) do
    config:write('  [\''.. k ..'\'] = {\n')
    for k2, v2 in pairsByKeys(v) do
      config:write('    '.. k2 ..' = '.. valueToFile(v2) ..',\n')
    end
    config:write('  },\n')
  end
  config:write('}\n')

  config:write('\nlocal trig_funcs = require \'store//Selene//triggerFunctions\'\n')

  config:write('\nfor name, func in pairs(trig_funcs) do if conf.chat_triggers[name].func then conf.chat_triggers[name].func = func end end\n')

  config:write('\nconf.identical_spam = {\n')
  for k, v in pairsByKeys(conf.identical_spam) do
    if type(v) != 'function' then
      config:write('  '.. k ..' = '.. valueToFile(v) ..',\n')
    end
  end
  config:write('}\n')

  config:write('\nconf.fast_spam = {\n')
  for k, v in pairsByKeys(conf.fast_spam) do
    if type(v) != 'function' then
      config:write('  '.. k ..' = '.. valueToFile(v) ..',\n')
    end
  end
  config:write('}\n')

  config:write('\nreturn conf')

  config:close()
end)

menu.divider(bot_settings, 'Settings')

menu.toggle(bot_settings, 'Run On Startup', {'runOnStartup'}, 'Automatically starts the bot when starting the sctipt.', function(toggle)
  conf.RUN_ON_STARTUP = toggle
end, conf.RUN_ON_STARTUP)

menu.text_input(bot_settings, 'Command prefix', {'commandPrefix'}, '', function(input)
  conf.COMMAND_PREFIX = input
end, conf.COMMAND_PREFIX)

menu.text_input(bot_settings, 'Response prefix', {'responsePrefix'}, '', function(input)
  conf.RESPONSE_PREFIX = input
end, conf.RESPONSE_PREFIX)

menu.toggle(bot_settings, 'Case Sensitive', {'caseSensitive'}, '', function(toggle)
  conf.CASE_SENSITIVE = toggle
end, conf.CASE_SENSITIVE)

local respond_to_option = menu.slider_text(bot_settings, 'Chat To Respond To', {'chatToRespondTo'}, '',{[1] = 'All', [2] = 'Team', [3] = 'Any'}, function(index)
  conf.CHAT_TO_RESPOND_TO = index
end, conf.CHAT_TO_RESPOND_TO)
menu.set_value(respond_to_option, conf.CHAT_TO_RESPOND_TO)

local respond_in_option = menu.slider_text(bot_settings, 'Chat To Respond In', {'chatToRespondIn'}, '', {[1] = 'All', [2] = 'Team', [3] = 'Same'}, function(index)
  conf.CHAT_TO_RESPOND_IN = index
end)
menu.set_value(respond_in_option, conf.CHAT_TO_RESPOND_IN)

menu.divider(bot_settings, 'Response Groups')

menu.toggle(bot_settings, 'Respond To User', {'respondToUser'}, '', function(toggle)
  conf.RESPOND_TO_USER = toggle
end, conf.RESPOND_TO_USER)

menu.toggle(bot_settings, 'Respond To Friends', {'respondToFriends'}, '', function(toggle)
  conf.RESPOND_TO_FRIENDS = toggle
end, conf.RESPOND_TO_FRIENDS)

menu.toggle(bot_settings, 'Respond To Strangers', {'respondToStrangers'}, '', function(toggle)
  conf.RESPOND_TO_STRANGERS = toggle
end, conf.RESPOND_TO_STRANGERS)

-----------------------
-- Commands
-----------------------

local command_list = menu.list(my_root, 'Commands', {}, 'Manage your text commands here.')

local function addNewCommand(command, response)
  if type(response) != 'string' then return end
  local list = menu.list(command_list, command, {}, '')
  local cmd = command

  menu.text_input(list, 'Command', {cmd ..'cmd'}, '', function(input)
    conf.command_list[input] = conf.command_list[cmd]
    cmd = input
    menu.set_menu_name(list, input)
    conf.command_list[command] = nil
  end, command)

  menu.text_input(list, 'Response', {cmd ..'res'}, '', function(input)
    conf.command_list[cmd] = input
  end, response)

  menu.action(list, 'Delete Command', {}, '', function()
    conf.command_list[command] = nil
    menu.delete(list)
  end)
end

menu.action(command_list, 'Add New Command', {}, '', function()
  conf.command_list['new'] = 'Default'
  addNewCommand('new', 'Default')
end)

menu.divider(command_list, 'Commands')

for cmd, res in pairsByKeys(conf.command_list) do
  addNewCommand(cmd, res)
end

-----------------------
-- Chat triggers
-----------------------

local chat_triggers = menu.list(my_root, 'Chat Triggers', {}, '')

for name, tbl in pairsByKeys(conf.chat_triggers) do
  menu.toggle(chat_triggers, name, {name}, '', function(toggle)
    tbl.active = toggle
  end, tbl.active)
end

-----------------------
-- Anti spam
-----------------------

local anti_spam = menu.list(my_root, 'Anti chat spam', {}, '')

menu.divider(anti_spam, 'Identical messages', {}, '')

menu.toggle(anti_spam, 'Anti Identical Message Spam', {'antiIdenticalMessageSpam'}, '', function(toggle)
  conf.identical_spam.active = toggle
end, conf.identical_spam.active)

menu.slider(anti_spam, 'Identical messages', {'identicalMessages'}, 'How many identical chat messages a player can send before getting kicked.', 2, 9999, conf.identical_spam.messages, 1, function(value)
  conf.identical_spam.messages = value
end)

local identicalMessages = {}
local function antiIdenticalSpam(msg)
  local pid = msg.pid
  if identicalMessages[pid] == nil then
    identicalMessages[pid] = {}
  end

  identicalMessages[pid][#identicalMessages[pid] + 1] = msg.txt

  if #identicalMessages[pid] < conf.identical_spam.messages then return end

  for i = 1, #identicalMessages[pid] - 1 do
    if identicalMessages[pid][#identicalMessages[pid]] != identicalMessages[pid][#identicalMessages[pid] - i] then
      identicalMessages[pid] = {}
        return
    end
    if i == #identicalMessages[pid] - 1 then
      local name = players.get_name(pid)
      menu.trigger_commands('kick'.. name)
      util.toast('Kicked '.. name ..' for chat spamming identical messages.')
      identicalMessages[pid] = nil
    end
  end
end

menu.divider(anti_spam, 'Fast messages', {}, '')

menu.toggle(anti_spam, 'Anti Fast Message Spam', {'antiFastMessageSpam'}, '', function(toggle)
  conf.fast_spam.active = toggle
end, conf.fast_spam.active)

menu.slider(anti_spam, 'Amount of messages', {'amountOfMessages'}, 'How many chat messages a player can send in the time frame before getting kicked.', 2, 9999, conf.fast_spam.messages, 1, function(value)
  conf.fast_spam.messages = value
end)

menu.slider(anti_spam, 'In Time', {'inTime'}, 'The time frame in seconds of how many fast messages can be sent before the player gets kicked.', 2, 9999, conf.fast_spam.time, 1, function(value)
  conf.fast_spam.time = value
end)

local fastMessages = {}
local function antiFastSpam(msg)
  local pid = msg.pid
  if fastMessages[pid] == nil then
    fastMessages[pid] = {}
  end

  fastMessages[pid][#fastMessages[pid] + 1] = util.current_unix_time_seconds()

  if #fastMessages[pid] < conf.fast_spam.messages then return end

  if fastMessages[pid][#fastMessages[pid]] - fastMessages[pid][1] <= conf.fast_spam.time then
    local name = players.get_name(pid)
    menu.trigger_commands('kick'.. name)
    util.toast('Kicked '.. name ..' for chat spamming messages too fast.')
    fastMessages[pid] = nil
  else
    local store = {}
    for i = 2, #fastMessages[pid] do
      store[i -1] = fastMessages[pid][i]
    end
    fastMessages[pid] = store
  end
end

local gtaBot = conf.RUN_ON_STARTUP
menu.toggle(my_root, 'Start Selene', {'startSelene'}, '', function(toggle)
  gtaBot = toggle
end, gtaBot)

-----------------------
-- Bot logic
-----------------------

function replaceNames(msg, sender_pid)
  msg = string.gsub(msg, '{user}', players.get_name(players.user()))
  return string.gsub(msg, '{sender}', players.get_name(sender_pid))
end

function getChatToRespondIn(team_chat, c)
  if c.CHAT_TO_RESPOND_IN == 3 then
    return team_chat
  end
  return c.CHAT_TO_RESPOND_IN == 2
end

function addPrefix(message)
  local prefix = ''
  if #conf.RESPONSE_PREFIX > 0 then
    prefix = conf.RESPONSE_PREFIX .. ' '
  end
  return prefix .. message
end

local function msgHasCommand(msg, cmd)
  if not conf.CASE_SENSITIVE then
    cmd = cmd:lower()
  end
  return string.sub(msg, 2, #cmd + 1) == cmd and (#msg == #cmd + 1 or string.sub(msg, #cmd + 2, #cmd + 2) == ' ')
end

local function respondToCommand(msg)
  for cmd, res in pairs(conf.command_list) do
    if msgHasCommand(msg.txt, cmd) then
      if type(res) == 'function' then
        res = res(msg, conf, string.gsub(string.match(msg.txt, ' .*'), ' ', ''))
      end

      if type(res) != 'string' then return end
      chat.send_message(addPrefix(replaceNames(res, msg.pid)), getChatToRespondIn(msg.tc, conf), true, true)
    end
  end
end

local function respondToMessage(msg)
  for name, triggers in pairs(conf.chat_triggers) do
    if not conf.chat_triggers[name].active then return end

    local match = conf.chat_triggers[name].matchAll
    for _, trigger in pairs(triggers.triggers) do
      match = msg.txt:find(replaceNames(trigger, msg.pid))

      if not match and conf.chat_triggers[name].matchAll or match and not conf.chat_triggers[name].matchAll then break end
    end

    if match then
      local res
      if conf.chat_triggers[name].func then
        res = conf.chat_triggers[name].func(msg, conf)
      else
        res = triggers.responses[1]
        if #triggers.responses > 1 then
          res = triggers.responses[math.random(1, #triggers.responses)]
        end
      end

      if type(res) != 'string' then return end
      chat.send_message(addPrefix(replaceNames(res, msg.pid)), getChatToRespondIn(msg.tc, conf), true, true)
      return
    end
  end
end

--credit to wiri (he is very cool)
function is_player_friend(pid)
	local pHandle = memory.alloc(104)
	NETWORK.NETWORK_HANDLE_FROM_PLAYER(pid, pHandle, 13)
	local isFriend = NETWORK.NETWORK_IS_HANDLE_VALID(pHandle, 13) and NETWORK.NETWORK_IS_FRIEND(pHandle)
	return isFriend
end

local function respondToGroup(pid)
  local isFriend = is_player_friend(pid)
  if pid == players.user() and conf.RESPOND_TO_USER then
    return true
  elseif isFriend and conf.RESPOND_TO_FRIENDS then
    return true
  end

  return not isFriend and conf.RESPOND_TO_STRANGERS
end

local function respondToChat(team_chat)
  if conf.CHAT_TO_RESPOND_TO == 3 then
    return true
  elseif team_chat and conf.CHAT_TO_RESPOND_TO == 2 then
    return true
  end

  return not team_chat and conf.CHAT_TO_RESPOND_TO == 1
end

chat.on_message(function(sender_pid, unused, message, team_chat)
  if not gtaBot or string.sub(message, 0, 1) == conf.RESPONSE_PREFIX or not respondToGroup(sender_pid) or not respondToChat(team_chat) then
    return
  end

  if not conf.CASE_SENSITIVE then
    message = message:lower()
  end

  local msg = {}
  msg.txt = message
  msg.pid = sender_pid
  msg.tc = team_chat

  if string.sub(message, 0, 1) == conf.COMMAND_PREFIX then
    respondToCommand(msg)
  else
    respondToMessage(msg)
  end

  if conf.identical_spam.active then
    antiIdenticalSpam(msg)
  end
  if conf.fast_spam.active then
    antiFastSpam(msg)
  end
end)

util.keep_running()
