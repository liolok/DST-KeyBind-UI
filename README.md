# KeyBind UI for Don't Starve Together

[中文说明](./README.zh.md)

Easy key binds for your mod. Beside mod configuration, also support hot-rebind in "Settings > Controls".

## Quick Start

In `modinfo.lua`, define all supported keys:

```lua
keys = { -- from STRINGS.UI.CONTROLSSCREEN.INPUTS[1] of strings.lua, need to match constants.lua too.
'Disabled', 'Escape', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'Print', 'ScrolLock', 'Pause',
'Disabled', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
'Disabled', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
'Disabled', 'Tab', 'CapsLock', 'LShift', 'LCtrl', 'LAlt', 'Space', 'RAlt', 'RCtrl', 'Period', 'Slash', 'RShift',
'Disabled', 'Minus', 'Equals', 'Backspace', 'LeftBracket', 'RightBracket', 'Backslash', 'Semicolon', 'Enter',
'Disabled', 'Up', 'Down', 'Left', 'Right', 'Insert', 'Delete', 'Home', 'End', 'PageUp', 'PageDown', -- navigation
'Disabled', 'Num 0', 'Num 1', 'Num 2', 'Num 3', 'Num 4', 'Num 5', 'Num 6', 'Num 7', 'Num 8', 'Num 9', -- numberic keypad
'Num Period', 'Num Divide', 'Num Multiply', 'Num Minus', 'Num Plus', 'Disabled',
}
for i = 1, #keys do
  keys[i] = { description = keys[i], data = 'KEY_' .. keys[i]:gsub('^Num ', 'KP_'):upper() }
end -- keys[1].description: 'Disabled', keys[1].data: 'KEY_DISABLED'
```

Then add a configuration:

```lua
configuration_options = {
  {
    name = 'keybind_1', -- config name for mod developer
    label = 'KeyBind 1', -- config name for player
    hover = 'Description for KeyBind 1', -- description for player
    default = 'KEY_F1', -- default key
    options = keys, -- all keys
  },
}
```

> Note: For `default`, select a `data` from `keys`.
>
> For example, use `default = 'KEY_DISABLED'` to bind no key by default.

Copy `keybind.lua` to your mod folder, import it and implement actual logic in `modmain.lua`:

```lua
modimport('keybind') -- relative path of keybind.lua

local function YourFn() print('Do your things here!') end

local handler = nil -- key event handlers

function KeyBind(_, key)
  if handler then handler:Remove() end -- disable old binding
  handler = key and GLOBAL.TheInput:AddKeyDownHandler(key, YourFn) or nil -- new binding or delete
end
```

> Note: First argument of function `KeyBind` is config name, in this case we only bind one key so no need of it.
>
> For more than one key binding example, see `modinfo.lua` and `modmain.lua` in this repository.

## Credit

This is my fork of rtk0c's [KeybindMagic](https://github.com/rtk0c/dont-starve-mods/tree/master/KeybindMagic),
mod configuration injection part was originally adapted from Tony's [Lazy Controls](https://steamcommunity.com/sharedfiles/filedetails/?id=2111412487) by me.
