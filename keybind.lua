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
local S = G.STRINGS.UI.CONTROLSSCREEN

local Widget = require('widgets/widget')
local Image = require('widgets/image')
local ImageButton = require('widgets/imagebutton')
local Text = require('widgets/text')
local OptionsScreen = require('screens/redux/optionsscreen')
local PopupDialogScreen = require('screens/redux/popupdialog')
local TEMPLATES = require('widgets/redux/templates')

local KEYS = modinfo.keys or {}

-- "KEY_*" to code number or nil
local function Raw(key) return G.rawget(G, key) end

-- code number to "KEY_*"
local valid = {}
for _, option in ipairs(KEYS) do
  local key = option.data
  local num = Raw(key)
  if num then valid[num] = key end
end

-- name or "- No Bind -"
local function Localize(key)
  local num = Raw(key)
  return num and S.INPUTS[1][num] or S.INPUTS[9][2]
end

--------------------------------------------------------------------------------
-- Button widget that pops up a dialog screen to bind key
-- Adapted from screens/redux/optionsscreen.lua: BuildControlGroup()
local BindButton = Class(Widget, function(self, param)
  Widget._ctor(self, modname .. ':KeyBindButton')
  self.OnBind = param.OnBind
  self.title = param.title
  self.default = param.default
  self.initial = param.initial

  self.changed_image = self:AddChild(Image('images/global_redux.xml', 'wardrobe_spinner_bg.tex'))
  self.changed_image:ScaleToSize(param.width, param.height)
  self.changed_image:SetTint(1, 1, 1, 0.3)
  self.changed_image:Hide()

  self.binding_btn = self:AddChild(ImageButton('images/global_redux.xml', 'blank.tex', 'spinner_focus.tex'))
  self.binding_btn:SetOnClick(function() self:PopupKeyBindDialog() end)
  self.binding_btn:ForceImageSize(param.width, param.height)
  self.binding_btn:SetText(Localize(param.initial))
  self.binding_btn:SetTextSize(param.text_size or 30)
  self.binding_btn:SetTextColour(param.text_color or G.UICOLOURS.GOLD_CLICKABLE)
  self.binding_btn:SetTextFocusColour(G.UICOLOURS.GOLD_FOCUS)
  self.binding_btn:SetFont(G.CHATFONT)

  self.unbinding_btn = self:AddChild(ImageButton('images/global_redux.xml', 'close.tex', 'close.tex'))
  self.unbinding_btn:SetPosition(param.width / 2 + (param.offset or 10), 0)
  self.unbinding_btn:SetOnClick(function() self:Bind('KEY_DISABLED') end)
  self.unbinding_btn:SetHoverText(S.UNBIND)
  self.unbinding_btn:SetScale(0.4, 0.4)

  self.focus_forward = self.binding_btn
end)

function BindButton:Bind(key)
  self.binding_btn:SetText(Localize(key))
  self.OnBind(key)
  if key == self.initial then
    self.changed_image:Hide()
  else
    self.changed_image:Show()
  end
end

function BindButton:PopupKeyBindDialog()
  local text = S.CONTROL_SELECT .. '\n\n' .. string.format(S.DEFAULT_CONTROL_TEXT, Localize(self.default))
  local buttons = { { text = S.CANCEL, cb = function() TheFrontEnd:PopScreen() end } }
  local dialog = PopupDialogScreen(self.title, text, buttons)

  dialog.OnRawKey = function(_, keycode, down)
    if down then return end -- wait for releasing
    local key = valid[keycode]
    if not key then return end -- validate code number
    self:Bind(key)
    TheFrontEnd:PopScreen()
    TheFrontEnd:GetSound():PlaySound('dontstarve/HUD/click_move')
    return true
  end

  TheFrontEnd:PushScreen(dialog)
end

--------------------------------------------------------------------------------
-- ModConfigurationScreen Injection
-- Replace StandardSpinner with BindButton like the one in OptionsScreen

AddClassPostConstruct('screens/redux/modconfigurationscreen', function(self)
  if self.modname ~= modname then return end -- avoid messing up other mods
  local bind_button = 'keybind_button@' .. modname -- avoid being messed up by other mods

  for _, widget in ipairs(self.options_scroll_list:GetListWidgets()) do
    local spinner = widget.opt.spinner
    local button = BindButton({
      width = 225, -- spinner_width
      height = 40, -- item_height
      text_size = 25, -- same as StandardSpinner's default
      text_color = G.UICOLOURS.GOLD, -- same as StandardSpinner's default
      offset = 0, -- put unbinding_btn closer
      OnBind = function(key)
        self.options[widget.real_index].value = key
        widget.opt.data.selected_value = key
        if key ~= widget.opt.data.initial_value then self:MakeDirty() end
      end,
    })
    button:SetPosition(spinner:GetPosition()) -- take original spinner's place

    widget.opt[bind_button] = widget.opt:AddChild(button)
    widget.opt.focus_forward = function() return button.shown and button or spinner end
  end

  local OldApplyDataToWidget = self.options_scroll_list.update_fn
  self.options_scroll_list.update_fn = function(context, widget, data, ...)
    OldApplyDataToWidget(context, widget, data, ...)
    local button = widget.opt[bind_button]
    button:Hide()
    if not data or data.is_header then return end

    for _, config in ipairs(modinfo.configuration_options) do
      if config.name == data.option.name then
        if config.options ~= KEYS then return end

        widget.opt.spinner:Hide()
        button.title = config.label
        button.default = config.default
        button.initial = data.initial_value
        button:Bind(data.selected_value)
        button:Show()

        return
      end
    end
  end

  self.options_scroll_list:RefreshView()
end)

--------------------------------------------------------------------------------
-- OptionsScreen Injection

local _key = {} -- to track bindings outside ModConfigurationScreen

-- Initialize bindings
AddGamePostInit(function()
  if type(KeyBind) ~= 'function' then return end
  for _, config in ipairs(modinfo.configuration_options) do
    if config.options == KEYS then
      local name = config.name
      local key = GetModConfigData(name)
      _key[name] = key
      KeyBind(name, Raw(key))
    end
  end
end)

-- Adapted from screens/redux/optionsscreen.lua: _BuildControls()
local BindEntry = Class(Widget, function(self, parent, conf)
  Widget._ctor(self, modname .. ':KeyBindEntry')
  local x = -371 -- x coord of the left edge
  local button_width = 250 -- controls_ui.action_btn_width
  local button_height = 48 -- controls_ui.action_height
  local label_width = 375 -- controls_ui.action_label_width

  self:SetHoverText(conf.hover, { offset_x = -60, offset_y = 60, wordwrap = true })
  self:SetScale(1, 1, 0.75)

  self.bg = self:AddChild(TEMPLATES.ListItemBackground(700, button_height))
  self.bg:SetPosition(-60, 0)
  self.bg:SetScale(1.025, 1)

  self.label = self:AddChild(Text(G.CHATFONT, 28, conf.label, G.UICOLOURS.GOLD_UNIMPORTANT))
  self.label:SetHAlign(G.ANCHOR_LEFT)
  self.label:SetRegionSize(label_width, 50)
  self.label:SetPosition(x + label_width / 2, 0)
  self.label:SetClickable(false)

  self.button = self:AddChild(BindButton({
    title = conf.label,
    default = conf.default,
    initial = _key[conf.name],
    width = button_width,
    height = button_height,
    OnBind = function(key)
      if _key[conf.name] ~= key then parent:MakeDirty() end
      _key[conf.name] = key
    end,
  }))
  self.button:SetPosition(x + label_width + 15 + button_width / 2, 0)

  -- rtk0c: OptionsScreen:RefreshControls() assumes the existence of these, add them to make it not crash.
  self.controlId, self.control = 0, {}
  self.changed_image = { Show = function() end, Hide = function() end }
  self.binding_btn = { SetText = function() end } -- OnControlMapped() calls this when first item changed

  self.focus_forward = self.button
end)

local Header = Class(Widget, function(self, title)
  Widget._ctor(self, modname .. ':Header')

  self.txt = self:AddChild(Text(G.HEADERFONT, 30, title, G.UICOLOURS.GOLD_SELECTED))
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

-- Add mod name header and keybind entries to the list in "Options > Controls"
AddClassPostConstruct('screens/redux/optionsscreen', function(self)
  local keybinds = {}
  for _, config in ipairs(modinfo.configuration_options) do
    if _key[config.name] then table.insert(keybinds, config) end
  end
  if #keybinds == 0 then return end
  -- rtk0c: Reusing the same list is fine, per the current logic in ScrollableList:SetList();
  -- Don't call ScrollableList:AddItem() one by one to avoid wasting time recalcuating the list size.
  local cl = self.kb_controllist
  table.insert(cl.items, cl:AddChild(Header(modinfo.name)))
  for _, config in ipairs(keybinds) do
    table.insert(cl.items, cl:AddChild(BindEntry(self, config))) end
  end
  cl:SetList(cl.items, true)
end)

-- Sync bindings to mod config when saving in OptionsScreen
local OldOptionsScreenSave = OptionsScreen.Save
function OptionsScreen:Save(...)
  for config_name, key in pairs(_key) do
    KeyBind(config_name, Raw(key)) -- let mod change binding
    G.KnownModIndex:SetConfigurationOption(modname, config_name, key)
  end
  G.KnownModIndex:SaveHostConfiguration(modname) -- save to disk
  return OldOptionsScreenSave(self, ...)
end
