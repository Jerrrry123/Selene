local trig_funcs = {}

trig_funcs['Kick Toxics'] = function(msg, conf)
  menu.trigger_commands('kick'.. players.get_name(msg.pid))
  return 'Kicked {sender} for being toxic in chat.'
end

return trig_funcs
