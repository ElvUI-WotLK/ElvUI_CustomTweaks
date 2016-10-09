local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule("UnitFrames")
local CT = E:GetModule("CustomTweaks")
local isEnabled = E.private["unitframe"].enable and E.private["CustomTweaks"] and E.private["CustomTweaks"]["AuraIconText"] and true or false

--Cache global variables
local CreateFrame = CreateFrame

P["CustomTweaks"]["AuraIconText"] = {
	["durationTextPos"] = "TOPLEFT",
	["durationTextOffsetX"] = 3,
	["durationTextOffsetY"] = -3,
	["stackTextPos"] = "BOTTOMRIGHT",
	["stackTextOffsetX"] = 1,
	["stackTextOffsetY"] = 2,
	["hideDurationText"] = false,
	["hideStackText"] = false,
	["durationFilterOwner"] = false,
	["durationThreshold"] = -1,
	["stackFilterOwner"] = false,
}

local function ConfigTable()
	E.Options.args.CustomTweaks.args.Unitframe.args.options.args.AuraIconText = {
		type = "group",
		name = "AuraIconText",
		get = function(info) return E.db.CustomTweaks.AuraIconText[info[#info]] end,
		set = function(info, value) E.db.CustomTweaks.AuraIconText[info[#info]] = value; E:StaticPopup_Show("CONFIG_RL"); end,
		args = {
			dur = {
				order = 1,
				type = "group",
				name = L["Duration Text"],
				guiInline = true,
				args = {
					hideDurationText = {
						order = 1,
						type = "toggle",
						name = L["Hide Text"],
						set = function(info, value) E.db.CustomTweaks.AuraIconText.hideDurationText = value; end,
						disabled = function() return not isEnabled end,
					},
					durationFilterOwner = {
						order = 2,
						type = "toggle",
						name = L["Hide From Others"],
						desc = L["Will hide duration text on auras that are not cast by you."],
						set = function(info, value) E.db.CustomTweaks.AuraIconText.durationFilterOwner = value; end,
						disabled = function() return (not isEnabled or E.db.CustomTweaks.AuraIconText.hideDurationText) end,
					},
					durationThreshold = {
						order = 3,
						type = "range",
						name = L["Threshold"],
						desc = L["Duration text will be hidden until it reaches this threshold (in seconds). Set to -1 to always show duration text."],
						set = function(info, value) E.db.CustomTweaks.AuraIconText.durationThreshold = value; end,
						disabled = function() return (not isEnabled or E.db.CustomTweaks.AuraIconText.hideDurationText) end,
						min = -1, max = 60, step = 1,
					},
					durationTextPos = {
						order = 4,
						type = "select",
						name = L["Position"],
						desc = L["Position of the duration text on the aura icon."],
						disabled = function() return not isEnabled end,
						values = {
							["BOTTOMLEFT"] = L["Bottom Left"],
							["BOTTOMRIGHT"] = L["Bottom Right"],
							["TOPLEFT"] = L["Top Left"],
							["TOPRIGHT"] = L["Top Right"],
							["CENTER"] = L["Center"],
						},
					},
					durationTextOffsetX = {
						order = 5,
						type = "range",
						name = L["X-Offset"],
						desc = L["Horizontal offset of the duration text."],
						disabled = function() return not isEnabled end,
						min = -20, max = 20, step = 1,
					},
					durationTextOffsetY = {
						order = 6,
						type = "range",
						name = L["Y-Offset"],
						desc = L["Vertical offset of the duration text."],
						disabled = function() return not isEnabled end,
						min = -20, max = 20, step = 1,
					},
				},
			},
			stack = {
				order = 2,
				type = "group",
				name = L["Stack Text"],
				guiInline = true,
				args = {
					hideStackText = {
						order = 1,
						type = "toggle",
						name = L["Hide Text"],
						set = function(info, value) E.db.CustomTweaks.AuraIconText.hideStackText = value; end,
						disabled = function() return not isEnabled end,
					},
					stackFilterOwner = {
						order = 2,
						type = "toggle",
						name = L["Hide From Others"],
						desc = L["Will hide stack text on auras that are not cast by you."],
						set = function(info, value) E.db.CustomTweaks.AuraIconText.stackFilterOwner = value; end,
						disabled = function() return (not isEnabled or E.db.CustomTweaks.AuraIconText.hideStackText) end,
					},
					stackTextPos = {
						order = 3,
						type = "select",
						name = L["Position"],
						desc = L["Position of the stack count on the aura icon."],
						disabled = function() return not isEnabled end,
						values = {
							["BOTTOMLEFT"] = L["Bottom Left"],
							["BOTTOMRIGHT"] = L["Bottom Right"],
							["TOPLEFT"] = L["Top Left"],
							["TOPRIGHT"] = L["Top Right"],
							["CENTER"] = L["Center"],
						},
					},
					spacer = {
						order = 4,
						type = "description",
						name = "",
					},
					stackTextOffsetX = {
						order = 5,
						type = "range",
						name = L["X-Offset"],
						desc = L["Horizontal offset of the stack count."],
						disabled = function() return not isEnabled end,
						min = -20, max = 20, step = 1,
					},
					stackTextOffsetY = {
						order = 6,
						type = "range",
						name = L["Y-Offset"],
						desc = L["Vertical offset of the stack count."],
						disabled = function() return not isEnabled end,
						min = -20, max = 20, step = 1,
					},
				},
			},
		},
	}
end
CT.Configs["AuraIconText"] = ConfigTable
if not isEnabled then return; end

local function UpdateAuraIconSettings(self, auras, noCycle)
	local frame = auras:GetParent()
	local type = auras.type
	if(noCycle) then
		frame = auras:GetParent():GetParent()
		type = auras:GetParent().type
	end
	if(not frame.db) then return end

	local db = frame.db[type]
	local index = 1
	if(db) then
		local config = E.db.CustomTweaks.AuraIconText
		if(not noCycle) then
			while(auras[index]) do
				local button = auras[index]
				button.text:Point(config.durationTextPos, config.durationTextOffsetX, config.durationTextOffsetY)
				button.count:Point(config.stackTextPos, config.stackTextOffsetX, config.stackTextOffsetY)

				if not button.helper then
					local helper = CreateFrame("Frame", nil, button)
					button.helper = helper
					button.helper:SetInside()
					button.helper:SetFrameStrata(button.cd.GetFrameStrata and button.cd:GetFrameStrata() or "HIGH")
					button.helper:SetFrameLevel(button.cd.GetFrameLevel and (button.cd:GetFrameLevel() + 2) or 20)
					button.count:SetParent(button.helper)
				end

				index = index + 1
			end
		else
			auras.text:Point(config.durationTextPos, config.durationTextOffsetX, config.durationTextOffsetY)
			auras.count:Point(config.stackTextPos, config.stackTextOffsetX, config.stackTextOffsetY)

			if not auras.helper then
				local helper = CreateFrame("Frame", nil, auras)
				auras.helper = helper
				auras.helper:SetInside()
				auras.helper:SetFrameStrata(auras.cd.GetFrameStrata and auras.cd:GetFrameStrata() or "HIGH")
				auras.helper:SetFrameLevel(auras.cd.GetFrameLevel and (auras.cd:GetFrameLevel() + 2) or 20)
				auras.count:SetParent(auras.helper)
			end
		end
	end
end
hooksecurefunc(UF, "UpdateAuraIconSettings", UpdateAuraIconSettings)

local function UpdateAuraTimer(self, elapsed)
	local hideDurationText = E.db.CustomTweaks.AuraIconText.hideDurationText
	local hideStackText = E.db.CustomTweaks.AuraIconText.hideStackText
	local durationThreshold = E.db.CustomTweaks.AuraIconText.durationThreshold
	local durationFilterOwner = E.db.CustomTweaks.AuraIconText.durationFilterOwner
	local stackFilterOwner = E.db.CustomTweaks.AuraIconText.stackFilterOwner
	local showText = true
	local showCount = true

	if ((durationThreshold > 0) and (self.expiration > durationThreshold)) or (durationFilterOwner and (self.owner ~= "player" and self.owner ~= "vehicle")) or (hideDurationText) then
		showText = false
	end

	if (stackFilterOwner and (self.owner ~= "player" and self.owner ~= "vehicle")) or (hideStackText) then
		showCount = false
	end

	self.text:SetAlpha(showText and 1 or 0)
	self.count:SetAlpha(showCount and 1 or 0)
end
hooksecurefunc(UF, "UpdateAuraTimer", UpdateAuraTimer)

local function SetOnUpdate(button)
	if button:GetScript('OnUpdate') and not button.isUpdatedCT then
		button.nextupdate = -1
		button:SetScript('OnUpdate', UF.UpdateAuraTimer)
		button.isUpdatedCT = true
	end
end

local function ResetOnUpdate(unitframe)
	if not unitframe.Buffs and not unitframe.Debuffs then return; end
	
	if unitframe.Buffs then
		for i = 1, #unitframe.Buffs do
			local button = unitframe.Buffs[i]
			if(button and button:IsShown()) then
				SetOnUpdate(button)
			end
		end
	end
	
	if unitframe.Debuffs then
		for i = 1, #unitframe.Debuffs do
			local button = unitframe.Debuffs[i]
			if(button and button:IsShown()) then
				SetOnUpdate(button)
			end
		end
	end
end

--Existing auras with a duration have their OnUpdate set before "UpdateAuraTimer" is hooked
--Duration or stack text will not be hidden for those aura buttons
--Look through all auras on all unitframes and update OnUpdate script if necessary
local function UpdateExistingAuras()
	for unit, unitName in pairs(UF.units) do
		local frameNameUnit = E:StringTitle(unitName)
		frameNameUnit = frameNameUnit:gsub("t(arget)", "T%1")
		
		local unitframe = _G["ElvUF_"..frameNameUnit]
		if unitframe then
			ResetOnUpdate(unitframe)
		end
	end

	for unit, unitgroup in pairs(UF.groupunits) do
		local frameNameUnit = E:StringTitle(unit)
		frameNameUnit = frameNameUnit:gsub("t(arget)", "T%1")
		
		local unitframe = _G["ElvUF_"..frameNameUnit]
		if unitframe then
			ResetOnUpdate(unitframe)
		end
	end
	
	for _, header in pairs(UF.headers) do
		local name = header.groupName
		local db = UF.db['units'][name]
		for i = 1, header:GetNumChildren() do
			local group = select(i, header:GetChildren())
			--group is Tank/Assist Frames, but for Party/Raid we need to go deeper
			ResetOnUpdate(group)

			for j = 1, group:GetNumChildren() do
				--Party/Raid unitbutton
				local unitbutton = select(j, group:GetChildren())
				ResetOnUpdate(unitbutton)
			end
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent(event)
	UpdateExistingAuras()
end)