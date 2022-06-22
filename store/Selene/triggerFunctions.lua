local trig_funcs = {}

trig_funcs.Censor = function(msg, conf)
  menu.trigger_commands('kick'.. players.get_name(msg.pid))
end

return trig_funcs
