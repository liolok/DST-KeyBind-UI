# 饥荒联机版键位绑定

[Documentation in English](./README.md)

简单方便的模组键位绑定。在模组配置之外，还支持在游戏内「设置 > 控制」页面更改配置，实时生效无需重启。

## 快速上手

在 `modinfo.lua` 中，定义所有支持的键位：

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

然后添加一个配置：

```lua
configuration_options = {
  {
    name = 'keybind_1', -- 开发者用的配置名称
    label = 'KeyBind 1', -- 玩家看到的配置名称
    hover = 'Description for KeyBind 1', -- 玩家看到的配置描述
    default = 'KEY_F1', -- 默认键位
    options = keys, -- 所有键位选择
  },
}
```

> 说明：`default` 应在 `keys` 的 `data` 中选择一个。
>
> 例如 `default = 'KEY_DISABLED'` 表示默认不绑定任何键位。

将 `keybind.lua` 复制到模组目录，在 `modmain.lua` 中导入并实现业务逻辑：

```lua
modimport('keybind') -- keybind.lua 实际所在的相对路径

local function YourFn() print('键位绑定的业务逻辑代码') end

local handler = nil -- 按键事件处理器

function KeyBind(_, key)
  if handler then handler:Remove() end -- 禁用旧绑定
  handler = key and GLOBAL.TheInput:AddKeyDownHandler(key, YourFn) or nil -- 新建绑定或无绑定
end
```

> 说明：函数 `KeyBind` 的第一个参数是配置名称，此处由于我们只绑定了一个键位所以不需要它。
>
> 对于多个键位的绑定，请参考本仓库的 `modinfo.lua` 和 `modmain.lua`。

## 致谢

原版是 rtk0c 的 [KeybindMagic](https://github.com/rtk0c/dont-starve-mods/tree/master/KeybindMagic)，
模组配置注入部分起初由我从 Tony 的 [Lazy Controls](https://steamcommunity.com/sharedfiles/filedetails/?id=2111412487) 改版而来。
