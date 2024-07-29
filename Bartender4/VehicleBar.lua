--[[
	Copyright (c) 2009, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")

-- register module
local VehicleBarMod = Bartender4:NewModule("Vehicle", "AceHook-3.0")

-- fetch upvalues
local ButtonBar = Bartender4.ButtonBar.prototype

local table_insert, setmetatable, pairs = table.insert, setmetatable, pairs

-- GLOBALS: MainMenuBarVehicleLeaveButton, CanExitVehicle

-- create prototype information
local VehicleBar = setmetatable({}, {__index = ButtonBar})

local defaults = { profile = Bartender4:Merge({
	enabled = true,
	visibility = {
		custom = true,
		customdata = "[target=vehicle,exists]show;hide"
	},
}, Bartender4.ButtonBar.defaults) }

function VehicleBarMod:OnInitialize()
	self.db = Bartender4.db:RegisterNamespace("Vehicle", defaults)
	if self.blizzardVehicle then
		self:SetEnabledState(false)
	else
		self:SetEnabledState(self.db.profile.enabled)
	end
end

function VehicleBarMod:OnEnable()
	if self.blizzardVehicle then
		self:Disable()
		return
	end
	if not self.bar then
		self.bar = setmetatable(Bartender4.ButtonBar:Create("Vehicle", self.db.profile, L["Vehicle Bar"], true), {__index = VehicleBar})
		local buttons = {VehicleMenuBarLeaveButton, VehicleMenuBarPitchUpButton, VehicleMenuBarPitchDownButton}
		self.bar.buttons = buttons

		VehicleBarMod.button_count = 3

		for i,v in pairs(buttons) do
			v:SetParent(self.bar)
			v:Show()
			v.ClearSetPoint = self.bar.ClearSetPoint
		end
	end

	VehicleMenuBarPitchUpButton:GetNormalTexture():SetTexture([[Interface\Vehicles\UI-Vehicles-Button-Pitch-Up]])
	VehicleMenuBarPitchUpButton:GetNormalTexture():SetTexCoord(0.21875, 0.765625, 0.234375, 0.78125)
	VehicleMenuBarPitchUpButton:GetPushedTexture():SetTexture([[Interface\Vehicles\UI-Vehicles-Button-Pitch-Down]])
	VehicleMenuBarPitchUpButton:GetPushedTexture():SetTexCoord(0.21875, 0.765625, 0.234375, 0.78125)

	VehicleMenuBarPitchDownButton:GetNormalTexture():SetTexture([[Interface\Vehicles\UI-Vehicles-Button-PitchDown-Up]])
	VehicleMenuBarPitchDownButton:GetNormalTexture():SetTexCoord(0.21875, 0.765625, 0.234375, 0.78125)
	VehicleMenuBarPitchDownButton:GetPushedTexture():SetTexture([[Interface\Vehicles\UI-Vehicles-Button-PitchDown-Down]])
	VehicleMenuBarPitchDownButton:GetPushedTexture():SetTexCoord(0.21875, 0.765625, 0.234375, 0.78125)

	VehicleMenuBarLeaveButton:GetNormalTexture():SetTexture([[Interface\Vehicles\UI-Vehicles-Button-Exit-Up]])
	VehicleMenuBarLeaveButton:GetNormalTexture():SetTexCoord(0.140625, 0.859375, 0.140625, 0.859375)
	VehicleMenuBarLeaveButton:GetPushedTexture():SetTexture([[Interface\Vehicles\UI-Vehicles-Button-Exit-Down]])
	VehicleMenuBarLeaveButton:GetPushedTexture():SetTexCoord(0.140625, 0.859375, 0.140625, 0.859375)

	self:RawHook("MainMenuBarVehicleLeaveButton_Update", true)
	self.bar:Enable()
	self:ToggleOptions()
	self:ApplyConfig()
end

function VehicleBarMod:OnDisable()
	Bartender4.modulePrototype.OnDisable(self)
	VehicleMenuBarPitchUpButton:SetParent(VehicleMenuBar)
	VehicleMenuBarPitchUpButton:ClearAllPoints()
	VehicleMenuBarPitchDownButton:SetParent(VehicleMenuBar)
	VehicleMenuBarPitchDownButton:ClearAllPoints()
	VehicleMenuBarLeaveButton:SetParent(VehicleMenuBar)
	VehicleMenuBarLeaveButton:ClearAllPoints()
end

function VehicleBarMod:ApplyConfig()
	self.bar:ApplyConfig(self.db.profile)
end

VehicleBar.button_width = 40
VehicleBar.button_height = 40
VehicleBar.LBFOverride = true

local function ShouldVehicleButtonBeShown()
	return CanExitVehicle() or UnitOnTaxi("player")
end

function VehicleBarMod:MainMenuBarVehicleLeaveButton_Update()
	if ShouldVehicleButtonBeShown() then
		MainMenuBarVehicleLeaveButton:Show()
		MainMenuBarVehicleLeaveButton:Enable()
	else
		MainMenuBarVehicleLeaveButton:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]], "ADD")
		MainMenuBarVehicleLeaveButton:UnlockHighlight()
		MainMenuBarVehicleLeaveButton:Hide()
	end
end

function VehicleBar:ApplyConfig(config)
	ButtonBar.ApplyConfig(self, config)

	if not self.config.position.x then
		self:ClearSetPoint("CENTER", 120, 27)
		self:SavePosition()
	end

	self:UpdateButtonLayout()
end
