# KeyBind UI for Don't Starve Together

[中文说明](./README.zh.md)

Easy key binds for your mod. Beside mod configuration, also support hot-rebind in "Settings > Controls".

## Quick Start

In `modinfo.lua`, define all supported keys:

```lua
local keyboard = { -- from STRINGS.UI.CONTROLSSCREEN.INPUTS[1] of strings.lua, need to match constants.lua too.
  { 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'Print', 'ScrolLock', 'Pause' },
  { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' },
  { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M' },
  { 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' },
  { 'Escape', 'Tab', 'CapsLock', 'LShift', 'LCtrl', 'LSuper', 'LAlt' },
  { 'Space', 'RAlt', 'RSuper', 'RCtrl', 'RShift', 'Enter', 'Backspace' },
  { 'Tilde', 'Minus', 'Equals', 'LeftBracket', 'RightBracket', 'Backslash', 'Semicolon', 'Period', 'Slash' }, -- punctuation
  { 'Up', 'Down', 'Left', 'Right', 'Insert', 'Delete', 'Home', 'End', 'PageUp', 'PageDown' }, -- navigation
  { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'Period', 'Divide', 'Multiply', 'Minus', 'Plus' }, -- numberic keypad
}
local key_disabled = { description = 'Disabled', data = 'KEY_DISABLED' }
keys = { key_disabled }
for i = 1, #keyboard do
  for j = 1, #keyboard[i] do
    local str = keyboard[i][j]
    local desc = i == #keyboard and 'NumPad ' .. str or str
    keys[#keys + 1] = { description = desc, data = 'KEY_' .. str:upper() }
  end
  keys[#keys + 1] = key_disabled
end
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
