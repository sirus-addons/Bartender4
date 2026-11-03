--[[
	Copyright (c) 2009, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")

-- fetch upvalues
local Bar = Bartender4.Bar.prototype

local defaults = { profile = Bartender4:Merge({
	enabled = false,
}, Bartender4.Bar.defaults) }

local RepBarMod, XPBarMod

local function CaptureStatusBar(container)
	local bar = container.shownBar
	local module = (bar == ReputationWatchBar and RepBarMod) or (bar == MainMenuExpBar and XPBarMod)
	if module and module:IsEnabled() and not container.isInEditMode then
		bar:SetParent(module.bar)
		module.bar:PerformLayout()
		container:HideBase()
	end
end

local statusBarsHooked
local function CaptureStatusBars()
	if not statusBarsHooked then
		statusBarsHooked = true
		for _, container in ipairs(StatusTrackingBarManager.barContainers) do
			hooksecurefunc(container, "UpdateShownState", CaptureStatusBar)
		end
	end
	for _, container in ipairs(StatusTrackingBarManager.barContainers) do
		CaptureStatusBar(container)
	end
end

local function EnableStatusBar(module, id, name, content)
	if not module.bar then
		module.bar = setmetatable(Bartender4.Bar:Create(id, module.db.profile, name), {__index = module.prototype})
		module.bar.content = content

		if not Bartender4.IsDF then
			content:SetParent(module.bar)
			content:Show()
			content:SetFrameLevel(module.bar:GetFrameLevel() + 1)
		end
	end
	module.bar:Enable()
	module:ToggleOptions()
	module:ApplyConfig()
	if Bartender4.IsDF then
		CaptureStatusBars()
	end
end

-- register module
RepBarMod = Bartender4:NewModule("RepBar")

-- create prototype information
local RepBar = setmetatable({}, {__index = Bar})
RepBarMod.prototype = RepBar

function RepBarMod:OnInitialize()
	self.db = Bartender4.db:RegisterNamespace("RepBar", defaults)
	self:SetEnabledState(self.db.profile.enabled)
end

function RepBarMod:OnEnable()
	if not self.bar and not Bartender4.IsDF then
		hooksecurefunc("ReputationWatchBar_Update", function() self.bar:PerformLayout() end)
	end
	EnableStatusBar(self, "Rep", L["Reputation Bar"], ReputationWatchBar)
end

function RepBarMod:ApplyConfig()
	self.bar:ApplyConfig(self.db.profile)
end

function RepBar:ApplyConfig(config)
	Bar.ApplyConfig(self, config)

	self:PerformLayout()
end

function RepBar:PerformLayout()
	local bar = self.content
	if Bartender4.IsDF then
		if bar:GetParent() ~= self then return end
		self:SetSize(bar:GetWidth() + 6, bar:GetHeight() + 6)
		bar:ClearAllPoints()
		bar:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -3)
	else
		self:SetSize(1032, 21)
		bar:ClearAllPoints()
		bar:SetPoint("TOPLEFT", self, "TOPLEFT", 5, -3)
	end
end

RepBar.ClickThroughSupport = true
function RepBar:ControlClickThrough()
	self.content:EnableMouse(not self.config.clickthrough)
end


-- register module
XPBarMod = Bartender4:NewModule("XPBar")

-- create prototype information
local XPBar = setmetatable({}, {__index = Bar})
XPBarMod.prototype = XPBar

function XPBarMod:OnInitialize()
	self.db = Bartender4.db:RegisterNamespace("XPBar", defaults)
	self:SetEnabledState(self.db.profile.enabled)
end

function XPBarMod:OnEnable()
	EnableStatusBar(self, "XP", L["XP Bar"], MainMenuExpBar)
end

XPBarMod.ApplyConfig = RepBarMod.ApplyConfig
XPBar.ApplyConfig = RepBar.ApplyConfig
XPBar.PerformLayout = RepBar.PerformLayout

XPBar.ClickThroughSupport = true
XPBar.ControlClickThrough = RepBar.ControlClickThrough
