--[[
	Copyright (c) 2009, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")
-- register module
local MicroMenuMod = Bartender4:NewModule("MicroMenu", "AceHook-3.0")

-- fetch upvalues
local ButtonBar = Bartender4.ButtonBar.prototype

-- create prototype information
local MicroMenuBar = setmetatable({}, {__index = ButtonBar})

local table_insert = table.insert

local defaults = { profile = Bartender4:Merge({
	enabled = true,
	vertical = false,
	visibility = {
		possess = false,
	},
	padding = -3,
	position = {
		scale = 0.8,
	},
}, Bartender4.ButtonBar.defaults) }

function MicroMenuMod:OnInitialize()
	self.db = Bartender4.db:RegisterNamespace("MicroMenu", defaults)
	self:SetEnabledState(self.db.profile.enabled)
end

function MicroMenuMod:OnEnable()
	if not self.bar then
		self.bar = setmetatable(Bartender4.ButtonBar:Create("MicroMenu", self.db.profile, L["Micro Menu"]), {__index = MicroMenuBar})
		local buttons = {}

		for _, button in pairs(SHARED_BARTENDER4_MICROMENU_BUTTONS) do
			button = _G[button]

			if button then
				table_insert(buttons, button)
			end
		end
		
		self.bar.buttons = buttons

		MicroMenuMod.button_count = #buttons

		for i,v in pairs(buttons) do
			v:SetParent(self.bar)
			v:Show()
			v:SetFrameLevel(self.bar:GetFrameLevel() + 1)
			v.ClearSetPoint = self.bar.ClearSetPoint
		end

		self:SecureHook("UpdateMicroButtons")
	end
	self.bar:Enable()
	self:ToggleOptions()
	self:ApplyConfig()
end

function MicroMenuMod:ApplyConfig()
	self.bar:ApplyConfig(self.db.profile)
end

function MicroMenuMod:RestoreButtons()
	if not self:IsEnabled() then return end
	for k,v in pairs(self.bar.buttons) do
		v:SetParent(self.bar)
		v:Show()
	end
	self.bar:UpdateButtonLayout()
end

function MicroMenuMod:UpdateMicroButtons()
	if MainMenuBar.state == "player" then
		self:RestoreButtons()
	end
end

MicroMenuBar.button_width = 28
MicroMenuBar.button_height = 58
MicroMenuBar.vpad_offset = -21
function MicroMenuBar:ApplyConfig(config)
	ButtonBar.ApplyConfig(self, config)

	if not self.config.position.x then
		self:ClearSetPoint("CENTER", -105, 30)
		self:SavePosition()
	end

	self:UpdateButtonLayout()
end
