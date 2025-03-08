-- Developed by rtk0c and forked by liolok
-- https://github.com/liolok/DST-KeyBind-UI
-- https://github.com/rtk0c/dont-starve-mods/tree/master/KeybindMagic
--
-- It is not required, however very nice, to indicate so if you redistribute a
-- copy of this software if it contains changes not a part of the above source.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software to use, copy, modify, merge, publish, distribute without
-- limitation, subject to the following conditions:
--
-- The above permission and source notice shall be included in all copies or
-- substantial portions of the Software.

local G = GLOBAL
local C = G.UICOLOURS
local S = G.STRINGS.UI.CONTROLSSCREEN

local Widget = require('widgets/widget')
-- ModConfigurationScreen Injection
local Image = require('widgets/image')
local ImageButton = require('widgets/imagebutton')
local PopupDialogScreen = require('screens/redux/popupdialog')
-- OptionsScreen Injection
local Text = require('widgets/text')
local TEMPLATES = require('widgets/redux/templates')
local OptionsScreen = require('screens/redux/optionsscreen')

local MOUSE = { -- mouse button emoji => code number
  ['\238\132\130'] = 1002, -- Middle Mouse Button
  ['\238\132\131'] = 1005, -- Mouse Button 4
  ['\238\132\132'] = 1006, -- Mouse Button 5
}

-- "KEY_*" and mouse button emoji => code number or nil
local function Raw(key) return MOUSE[key] or G.rawget(G, key) end

-- code number to "KEY_*" and mouse button emoji
local str = {}
for _, option in ipairs(modinfo.keys) do
  local key = option.data
  local num = Raw(key)
  if num then str[num] = key end
end
local function Stringify(keycode) return str[keycode] end

-- "KEY_*" and mouse button emoji => name or "- No Bind -"
local function Localize(key)
  local num = Raw(key)
  return num and S.INPUTS[1][num] or S.INPUTS[9][2]
end

-- keybind configurations
local configs = {}
local is_keybind = {}
for _, config in ipairs(modinfo.configuration_options) do
  if config.options == modinfo.keys then
    table.insert(configs, config)
    is_keybind[config.name] = true
  end
end

-- initialize binds
AddGamePostInit(function()
  for name, _ in pairs(is_keybind) do
    KeyBind(name, Raw(GetModConfigData(name)))
  end
end)

--------------------------------------------------------------------------------
-- Button widget to show and change bind

-- Adapted from screens/redux/optionsscreen.lua: BuildControlGroup()
local BindButton = Class(Widget, function(self, param)
  Widget._ctor(self, modname .. ':KeyBindButton')
  self.title = param.title
  self.default = param.default
  self.initial = param.initial
  self.OnSet = param.OnSet
  self.OnChanged = param.OnChanged

  self.changed_image = self:AddChild(Image('images/global_redux.xml', 'wardrobe_spinner_bg.tex'))
  self.changed_image:ScaleToSize(param.width, param.height)
  self.changed_image:SetTint(1, 1, 1, 0.3)
  self.changed_image:Hide()

  self.binding_btn = self:AddChild(ImageButton('images/global_redux.xml', 'blank.tex', 'spinner_focus.tex'))
  self.binding_btn:SetOnClick(function() self:PopupKeyBindDialog() end)
  self.binding_btn:ForceImageSize(param.width, param.height)
  self.binding_btn:SetText(Localize(param.initial))
  self.binding_btn:SetTextSize(param.text_size or 30)
  self.binding_btn:SetTextColour(param.text_color or C.GOLD_CLICKABLE)
  self.binding_btn:SetTextFocusColour(C.GOLD_FOCUS)
  self.binding_btn:SetFont(G.CHATFONT)

  self.unbinding_btn = self:AddChild(ImageButton('images/global_redux.xml', 'close.tex', 'close.tex'))
  self.unbinding_btn:SetPosition(param.width / 2 + (param.offset or 10), 0)
  self.unbinding_btn:SetOnClick(function() self:Set('KEY_DISABLED') end)
  self.unbinding_btn:SetHoverText(S.UNBIND)
  self.unbinding_btn:SetScale(0.4, 0.4)

  self.focus_forward = self.binding_btn
end)

function BindButton:Set(key)
  self.binding_btn:SetText(Localize(key))
  self.OnSet(key)
  if key == self.initial then
    self.changed_image:Hide()
  else
    self.OnChanged()
    self.changed_image:Show()
  end
end

function BindButton:PopupKeyBindDialog()
  local function Setup(key)
    self:Set(key)
    TheFrontEnd:PopScreen()
    TheFrontEnd:GetSound():PlaySound('dontstarve/HUD/click_move')
  end
  local buttons = {}
  for key, _ in pairs(MOUSE) do
    for _, option in ipairs(modinfo.keys) do
      if key == option.data then -- only add if existing in real options
        table.insert(buttons, { text = key, cb = function() Setup(key) end })
        break
      end
    end
  end
  table.insert(buttons, { text = S.CANCEL, cb = function() TheFrontEnd:PopScreen() end })
  local text = S.CONTROL_SELECT .. '\n\n' .. string.format(S.DEFAULT_CONTROL_TEXT, Localize(self.default))
  local dialog = PopupDialogScreen(self.title, text, buttons)

  dialog.OnRawKey = function(_, keycode, down)
    local key = Stringify(keycode)
    if not key or down then return end -- wait for releasing valid key
    Setup(key)
    return true
  end

  TheFrontEnd:PushScreen(dialog)
end

-- unique child widget name to avoid being messed up by other mods
local BUTTON_NAME = 'keybind_button@' .. modname

--------------------------------------------------------------------------------
-- ModConfigurationScreen Injection
-- Replace StandardSpinner with BindButton like the one in OptionsScreen

AddClassPostConstruct('screens/redux/modconfigurationscreen', function(self)
  if self.modname ~= modname then return end -- avoid messing up other mods
  local list = self.options_scroll_list
  local OldApplyDataToWidget = list.update_fn
  list.update_fn = function(context, widget, data, ...)
    OldApplyDataToWidget(context, widget, data, ...)
    local opt = widget.opt
    local spinner = opt.spinner -- original StandardSpinner
    opt.focus_forward = spinner
    if opt[BUTTON_NAME] then opt[BUTTON_NAME]:Kill() end

    local config = data and data.option or {}
    if not is_keybind[config.name] then return end
    spinner:Hide()
    local button = BindButton({
      width = 225, -- spinner_width
      height = 40, -- item_height
      text_size = 25, -- same as StandardSpinner's default
      text_color = C.GOLD, -- same as StandardSpinner's default
      offset = 0, -- put unbinding_btn closer
      title = config.label,
      default = config.default,
      initial = data.initial_value,
      OnSet = function(key)
        self.options[widget.real_index].value = key
        data.selected_value = key
      end,
      OnChanged = function() self:MakeDirty() end,
    })
    button:SetPosition(spinner:GetPosition()) -- take its place
    button:Set(data.selected_value)
    button:Show()
    opt[BUTTON_NAME] = opt:AddChild(button)
    opt.focus_forward = button
  end
  list:RefreshView()
end)

--------------------------------------------------------------------------------
-- Widgets to append to item list in "Options/Settings > Controls"

-- config to key, to track binds in OptionsScreen
local _key = {}

-- Adapted from screens/redux/optionsscreen.lua: _BuildControls()
local BindEntry = Class(Widget, function(self, parent, config)
  Widget._ctor(self, modname .. ':KeyBindEntry')
  local x = -371 -- x coord of the left edge
  local button_width = 250 -- controls_ui.action_btn_width
  local button_height = 48 -- controls_ui.action_height
  local label_width = 375 -- controls_ui.action_label_width

  self:SetHoverText(config.hover, { offset_x = -60, offset_y = 60, wordwrap = true })
  self:SetScale(1, 1, 0.75)

  self.bg = self:AddChild(TEMPLATES.ListItemBackground(700, button_height))
  self.bg:SetPosition(-60, 0)
  self.bg:SetScale(1.025, 1)

  self.label = self:AddChild(Text(G.CHATFONT, 28, config.label, C.GOLD_UNIMPORTANT))
  self.label:SetHAlign(G.ANCHOR_LEFT)
  self.label:SetRegionSize(label_width, 50)
  self.label:SetPosition(x + label_width / 2, 0)
  self.label:SetClickable(false)

  self[BUTTON_NAME] = self:AddChild(BindButton({
    width = button_width,
    height = button_height,
    title = config.label,
    default = config.default,
    initial = _key[config],
    OnSet = function(key) _key[config] = key end,
    OnChanged = function() parent:MakeDirty() end,
  }))
  self[BUTTON_NAME]:SetPosition(x + label_width + 15 + button_width / 2, 0)

  -- rtk0c: OptionsScreen:RefreshControls() assumes the existence of these, add them to make it not crash.
  self.controlId, self.control = 0, {} -- use first item's ID
  self.changed_image = { Show = function() end, Hide = function() end }
  self.binding_btn = { SetText = function() end } -- OnControlMapped() calls this when first item changed

  self.focus_forward = self[BUTTON_NAME]
end)

local Header = Class(Widget, function(self, title)
  Widget._ctor(self, modname .. ':Header')

  self.txt = self:AddChild(Text(G.HEADERFONT, 32, title, C.GOLD_SELECTED))
  self.txt:SetPosition(-60, 0)

  self.bg = self:AddChild(TEMPLATES.ListItemBackground(700, 48)) -- only to be more scrollable
  self.bg:SetImageNormalColour(0, 0, 0, 0) -- total transparent
  self.bg:SetImageFocusColour(0, 0, 0, 0)
  self.bg:SetPosition(-60, 0)
  self.bg:SetScale(1.025, 1)

  -- rtk0c: OptionsScreen:RefreshControls() assumes the existence of these, add them to make it not crash.
  self.controlId, self.control = 0, {} -- use first item's ID
  self.changed_image = { Show = function() end, Hide = function() end }
  self.binding_btn = { SetText = function() end } -- OnControlMapped() calls this when first item changed
end)

--------------------------------------------------------------------------------
-- OptionsScreen Injection

-- Add mod name header and keybind entries to the list in "Options > Controls"
AddClassPostConstruct('screens/redux/optionsscreen', function(self)
  -- rtk0c: Reusing the same list is fine, per the current logic in ScrollableList:SetList();
  -- Don't call ScrollableList:AddItem() one by one to avoid wasting time recalcuating the list size.
  local list = self.kb_controllist
  local items = list.items
  if #configs > 0 then table.insert(items, list:AddChild(Header(modinfo.name))) end
  for _, config in ipairs(configs) do
    _key[config] = GetModConfigData(config.name)
    table.insert(items, list:AddChild(BindEntry(self, config)))
  end
  list:SetList(items, true)
end)

-- Reset to default binds after "Reset Binds"
local OldLoadDefaultControls = OptionsScreen.LoadDefaultControls
function OptionsScreen:LoadDefaultControls()
  for _, widget in ipairs(self.kb_controllist.items) do
    local button = widget[BUTTON_NAME]
    if button then button:Set(button.default) end
  end
  return OldLoadDefaultControls(self)
end

-- Sync binds to mod config after "Apply" and "Accept Changes"
local OldSave = OptionsScreen.Save
function OptionsScreen:Save(...)
  for config, key in pairs(_key) do
    KeyBind(config.name, Raw(key)) -- let mod change bind
    G.KnownModIndex:SetConfigurationOption(modname, config.name, key)
  end
  G.KnownModIndex:SaveHostConfiguration(modname) -- save to disk
  return OldSave(self, ...)
end
