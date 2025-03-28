-- This is a demo of how to work with keybind.lua to handle
-- key-down and key-down-and-up events, with both keyboard and mouse.
-- Of course, you're free to do anything with bound keys.
-- Configurations are defined in modinfo.lua

modimport('keybind')

local callback = {} -- config name to function called when the key event triggered
for i = 1, 12 do
  callback['keybind_' .. i] = function() print('KeyBind ' .. i) end
end
local is_holding = false
callback.keybind_hold = {
  down = function()
    is_holding = true
    print('Holding the Hold Key: Down')
  end,
  up = function()
    is_holding = false
    print('Holding the Hold Key: Up')
  end,
}

local handler = {} -- config name to key event handlers
function KeyBind(name, key)
  -- disable old binding
  if handler[name] then
    handler[name]:Remove()
    handler[name] = nil
  end

  -- no binding
  if not key then return end

  -- new binding
  if key >= 1000 then -- it's a mouse button
    if name == 'keybind_hold' then
      handler[name] = GLOBAL.TheInput:AddMouseButtonHandler(function(button, down, x, y)
        if button ~= key then return end
        local fn = down and 'down' or 'up'
        callback[name][fn]()
      end)
    else
      handler[name] = GLOBAL.TheInput:AddMouseButtonHandler(function(button, down, x, y)
        if button == key and down then callback[name]() end
      end)
    end
  else -- it's a keyboard key
    if name == 'keybind_hold' then
      handler[name] = GLOBAL.TheInput:AddKeyHandler(function(_key, down)
        if _key ~= key then return end
        local fn = down and 'down' or 'up'
        callback[name][fn]()
      end)
    else
      handler[name] = GLOBAL.TheInput:AddKeyDownHandler(key, callback[name])
    end
  end
end
