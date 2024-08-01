-- This is a demo of how to work with keybind.lua to handle key-down events.
-- Of course, you're free to do anything with bound keys.
-- Configurations are defined in modinfo.lua
modimport('keybind') -- load keybind.lua to get `Key`

local callback = {} -- config name to function called when the keybind is pressed
for i = 0, 9 do
  callback['keybind_' .. i] = function() print('KeyBind', i, 'Pressed!') end
end

local registered_handler = {} -- config name to key event handlers
Key.Bind = function(name, key)
  if registered_handler[name] then registered_handler[name]:Remove() end -- disable old binding
  registered_handler[name] = key and GLOBAL.TheInput:AddKeyDownHandler(key, callback[name]) or nil -- new binding or delete
end

for name, _ in pairs(callback) do
  Key.Bind(name, Key.Raw(GetModConfigData(name))) -- initialize binding
end
