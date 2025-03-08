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
  if key ~= nil then -- new binding
    if key >= 1000 then -- it's a mouse button
      handler[name] = GLOBAL.TheInput:AddMouseButtonHandler(function(button, down, x, y)
        if button == key and down then callback[name]() end
      end)
    else -- it's a keyboard key
      handler[name] = GLOBAL.TheInput:AddKeyDownHandler(key, callback[name])
    end
  else -- no binding
    handler[name] = nil
  end
end
