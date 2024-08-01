-- This is a demo of how to work with keybind.lua to handle key-down events.
-- Of course, you're free to do anything with bound keys.
-- Configurations are defined in modinfo.lua

modimport('keybind')

local callback = {} -- config name to function called when the key event triggered
for i = 1, 12 do
  callback['keybind_' .. i] = function() print('KeyBind ' .. i) end
end

local handler = {} -- config name to key event handlers
function KeyBind(name, key)
  if handler[name] then handler[name]:Remove() end -- disable old binding
  handler[name] = key and GLOBAL.TheInput:AddKeyDownHandler(key, callback[name]) or nil -- new binding or delete
end
