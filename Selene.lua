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
  end
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

  config:write('\nreturn conf')

  config:close()
end)


menu.text_input(bot_settings, 'Command prefix', {'commandPrefix'}, '', function(input)
  conf.COMMAND_PREFIX = input
end, conf.COMMAND_PREFIX)

menu.text_input(bot_settings, 'Response prefix', {'responsePrefix'}, '', function(input)
  conf.RESPONSE_PREFIX = input
end, conf.RESPONSE_PREFIX)

menu.toggle(bot_settings, 'Run On Startup', {'runOnStartup'}, 'Automatically starts the bot when starting the sctipt.', function(toggle)
  conf.RUN_ON_STARTUP = toggle
end, conf.RUN_ON_STARTUP)

menu.toggle(bot_settings, 'Case Sensitive', {'caseSensitive'}, '', function(toggle)
  conf.CASE_SENSITIVE = toggle
end, conf.CASE_SENSITIVE)

menu.toggle(bot_settings, 'Only Respond To Team Chat', {'caseSensitive'}, '', function(toggle)
  conf.ONLY_RESPOND_TO_TEAM_CHAT = toggle
end, conf.ONLY_RESPOND_TO_TEAM_CHAT)

local respond_option = menu.slider_text(bot_settings, 'Chat To Respond In', {'chatToRespondIn'}, '', {[1] = 'All', [2] = 'Team', [3] = 'Same'}, function(index)
  conf.CHAT_TO_RESPOND_IN = index
end)
menu.set_value(respond_option, conf.CHAT_TO_RESPOND_IN)

menu.toggle(bot_settings, 'Respond In Team Chat', {'caseSensitive'}, '', function(toggle)
  conf.ONLY_RESPOND_IN_TEAM_CHAT = toggle
end, conf.RESPOND_IN_TEAM_CHAT)

menu.toggle(bot_settings, 'Only Respond To User', {'onlyRespondToUser'}, '', function(toggle)
  conf.ONLY_RESPOND_TO_USER = toggle
end, conf.ONLY_RESPOND_TO_USER)

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

menu.divider(command_list, 'Commands', {}, '')

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

local gtaBot = conf.RUN_ON_STARTUP
menu.toggle(my_root, 'Turn On Bot', {'bot'}, '', function(toggle)
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
        res = res(msg, conf, string.match(msg.txt, ' .*'))
      end
      if type(res) != 'string' then return end
      chat.send_message(addPrefix(replaceNames(res, msg.pid)), getChatToRespondIn(msg.tc, conf), true, true)
    end
  end
end

local function respondToMessage(msg)
  for name, triggers in pairs(conf.chat_triggers) do
    if not conf.chat_triggers[name].active then return end

    local matchAll = true
    for _, trigger in pairs(triggers.triggers) do
      matchAll = msg.txt:find(trigger)
      if not matchAll then break end
    end

    if matchAll then
      local res = triggers.responses[1]
      if #triggers.responses > 1 then
        res = triggers.responses[math.random(1, #triggers.responses)]
      end
      chat.send_message(addPrefix(replaceNames(res, msg.pid)), getChatToRespondIn(msg.tc, conf), true, true)
      return
    end
  end
end

chat.on_message(function(sender_pid, unused, message, team_chat)
  if not gtaBot or (not team_chat and conf.ONLY_RESPOND_TO_TEAM_CHAT) or string.sub(message, 0, 1) == conf.RESPONSE_PREFIX or (sender_pid != players.user() and conf.ONLY_RESPOND_TO_USER) then return end

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
end)

util.keep_running()
