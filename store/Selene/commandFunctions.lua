local cmd_funcs = {}

cmd_funcs.date = function()
  return os.date('%x')
end

cmd_funcs.day = function()
  return os.date('%A')
end

cmd_funcs.time = function()
  return os.date('%H:%M:%S')
end

cmd_funcs.clear = function(msg, conf)
  for i = 0, 10 do
  chat.send_message('_', getChatToRespondIn(msg.tc, conf), true, true)
  end
end

cmd_funcs.countdown = function(msg, conf, param)
  param = tonumber(param)
  if type(param) != 'number' then util.toast('Invalid command parameter') return end

  for i = param, 1, -1 do
  chat.send_message(addPrefix(i), getChatToRespondIn(msg.tc, conf), true, true)
  AUDIO.PLAY_SOUND_FROM_ENTITY(-1, 'Checkpoint', PLAYER.GET_PLAYER_PED(msg.pid), 'Car_Club_Races_Sprint_Challenge_Sounds', true, true)
  util.yield(1000)
  end
  AUDIO.PLAY_SOUND_FROM_ENTITY(-1, 'Checkpoint_Finish_Winner', PLAYER.GET_PLAYER_PED(msg.pid), 'DLC_Tuner_Car_Meet_Test_Area_Events_Sounds', true, true)
  return 'Goooo!'
end

local function toTime(time)
  local format = string.sub(time, #time -2,#time)
  if not (format == 'min' or format == 'sec') then return end

  time = tonumber(string.sub(time, #time -4,#time -3))
  if type(time) != 'number' then
  time = tonumber(string.sub(time, #time -3,#time -3))
  if type(time) != 'number' then
  return
  end
  end

  if time > 60 or time < 1 then return end


  if format == 'min' then
  time *= 60
  end
  return time
end

cmd_funcs.settimer = function(msg, conf, param)
  local time = toTime(param)
  if time == nil then util.toast('Invalid command parameter') return end

  chat.send_message('Started '.. param ..' timer' , getChatToRespondIn(msg.tc, conf), true, true)
  for i = time, 1, -1 do
  util.yield(1000)
  end
  return players.get_name(msg.pid) ..'\'s '..  param ..' timer just ended!'
end

cmd_funcs.help = function(msg, conf)
  for i = 0, 50 do
  local message = 'Commands:\n'
  for k, v in pairsByKeys(conf.command_list) do
  message = message .. conf.COMMAND_PREFIX .. k ..'\n'
  end
  util.toast(message)
  util.yield(200)
  end
end

cmd_funcs.crashme = function(msg, conf)
  if msg.pid == players.user() then
  while true do end
  end

  menu.trigger_commands('crash'.. players.get_name(msg.pid))
  menu.trigger_commands('ngcrash'.. players.get_name(msg.pid))
  menu.trigger_commands('footlettuce'.. players.get_name(msg.pid))
end

cmd_funcs.leave = function(msg, conf)
  if msg.pid == players.user() then
  menu.trigger_commands('go public')
  return
  end

  menu.trigger_commands('kick'.. players.get_name(msg.pid))
end

local editions = {
  [0] = '(free)',
  [1] = 'basic',
  [2] = 'regular',
  [3] = 'ultimate',
}

cmd_funcs.edition = function(msg, conf)
  return '{user} has stand '.. editions[menu.get_edition()]
end

return cmd_funcs
