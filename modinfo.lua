name = 'KeyBind UI Demo'
author = 'rtk0c, liolok'
description = 'https://github.com/liolok/DST-KeyBind-UI'
version = '1.0'
api_version = 10
dst_compatible = true
client_only_mod = true

-- stylua: ignore
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
end

local boolean = { { description = 'No', data = false }, { description = 'Yes', data = true } }

local numbers = {}
for i = 0, 10 do
  numbers[i + 1] = { description = i, data = i }
end

local function Header(title) return { name = title, options = { { description = '', data = 0 } }, default = 0 } end

configuration_options = {
  Header('Section 1'),
  {
    name = 'keybind_1',
    label = 'KeyBind 1',
    hover = 'Description for KeyBind 1',
    default = 'KEY_F1',
    options = keys,
  },
  {
    name = 'keybind_2',
    label = 'KeyBind 2',
    hover = 'Description for KeyBind 2',
    default = 'KEY_F2',
    options = keys,
  },
  {
    name = 'keybind_3',
    label = 'KeyBind 3',
    hover = 'Description for KeyBind 3',
    default = 'KEY_F3',
    options = keys,
  },
  {
    name = 'keybind_4',
    label = 'KeyBind 4',
    hover = 'Description for KeyBind 4',
    default = 'KEY_F4',
    options = keys,
  },
  {
    name = 'keybind_5',
    label = 'KeyBind 5',
    hover = 'Description for KeyBind 5',
    default = 'KEY_F5',
    options = keys,
  },
  {
    name = 'keybind_6',
    label = 'KeyBind 6',
    hover = 'Description for KeyBind 6',
    default = 'KEY_F6',
    options = keys,
  },
  Header('Section 2'),
  {
    name = 'keybind_7',
    label = 'KeyBind 7',
    hover = 'Description for KeyBind 7',
    default = 'KEY_F7',
    options = keys,
  },
  {
    name = 'keybind_8',
    label = 'KeyBind 8',
    hover = 'Description for KeyBind 8',
    default = 'KEY_F8',
    options = keys,
  },
  {
    name = 'keybind_9',
    label = 'KeyBind 9',
    hover = 'Description for KeyBind 9',
    default = 'KEY_F9',
    options = keys,
  },
  {
    name = 'keybind_10',
    label = 'KeyBind 10',
    hover = 'Description for KeyBind 10',
    default = 'KEY_F10',
    options = keys,
  },
  {
    name = 'keybind_11',
    label = 'KeyBind 11',
    hover = 'Description for KeyBind 11',
    default = 'KEY_F11',
    options = keys,
  },
  {
    name = 'keybind_12',
    label = 'KeyBind 12',
    hover = 'Description for KeyBind 12',
    default = 'KEY_F12',
    options = keys,
  },
  {
    name = 'boolean',
    label = 'Boolean',
    hover = 'Description for Boolean',
    options = boolean,
    default = false,
  },
  {
    name = 'number',
    label = 'Number',
    hover = 'Description for Number',
    options = numbers,
    default = 0,
  },
}
