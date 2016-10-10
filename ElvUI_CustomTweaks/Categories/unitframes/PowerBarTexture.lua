local E, L, V, P, G = unpack(ElvUI)
local LSM = LibStub("LibSharedMedia-3.0");
local UF = E:GetModule("UnitFrames")
local CT = E:GetModule("CustomTweaks")
local isEnabled = E.private["unitframe"].enable and E.private["CustomTweaks"] and E.private["CustomTweaks"]["PowerBarTexture"] and true or false

--Cache global variables
local _G = _G
local pairs = pairs
local twipe = table.wipe

---
-- GLOBALS: AceGUIWidgetLSMlists
---

P["CustomTweaks"]["PowerBarTexture"] = {
	["powerstatusbar"] = "ElvUI Norm",
}

local UpdateStatusBars
local BuildTable
local powerbars = {}

local function ConfigTable()
	E.Options.args.CustomTweaks.args.Unitframe.args.options.args.PowerBarTexture = {
		type = "group",
		name = "PowerBarTexture",
		get = function(info) return E.db.CustomTweaks.PowerBarTexture[info[#info]] end,
		set = function(info, value) E.db.CustomTweaks.PowerBarTexture[info[#info]] = value; BuildTable(); UpdateStatusBars() end,
		args = {
			powerstatusbar = {
				order = 1,
				type = "select", dialogControl = "LSM30_Statusbar",
				name = L["PowerBar Texture"],
				disabled = function() return not isEnabled end,
				values = AceGUIWidgetLSMlists.statusbar,
			},
		},
	}
end
CT.Configs["PowerBarTexture"] = ConfigTable
if not isEnabled then return; end

function BuildTable()
	twipe(powerbars)

	for _, unitName in pairs(UF.units) do
		local frameNameUnit = E:StringTitle(unitName)
		frameNameUnit = frameNameUnit:gsub("t(arget)", "T%1")
		
		local unitframe = _G["ElvUF_"..frameNameUnit]
		if unitframe and unitframe.Power then powerbars[unitframe.Power] = true end
	end
	
	for unit, unitgroup in pairs(UF.groupunits) do
		local frameNameUnit = E:StringTitle(unit)
		frameNameUnit = frameNameUnit:gsub("t(arget)", "T%1")
		
		local unitframe = _G["ElvUF_"..frameNameUnit]
		if unitframe and unitframe.Power then powerbars[unitframe.Power] = true end
	end
	
	for _, header in pairs(UF.headers) do
		for i = 1, header:GetNumChildren() do
			local group = select(i, header:GetChildren())
			--group is Tank/Assist Frames, but for Party/Raid we need to go deeper
			for j = 1, group:GetNumChildren() do
				--Party/Raid unitbutton
				local unitbutton = select(j, group:GetChildren())
				if unitbutton.Power then powerbars[unitbutton.Power] = true end
			end
		end
	end
end
BuildTable()

function UpdateStatusBars()
	local statusBarTexture = LSM:Fetch("statusbar", E.db.CustomTweaks.PowerBarTexture.powerstatusbar)
	for powerbar in pairs(powerbars) do
		if powerbar and powerbar:GetObjectType() == "StatusBar" and not powerbar.isTransparent then
			powerbar:SetStatusBarTexture(statusBarTexture)
		elseif powerbar and powerbar:GetObjectType() == "Texture" then
			powerbar:SetStatusBarTexture(statusBarTexture)
		end
	end
end
hooksecurefunc(UF, "Update_StatusBars", UpdateStatusBars)
hooksecurefunc(UF, "CreateAndUpdateUF", UpdateStatusBars)
hooksecurefunc(UF, "CreateAndUpdateUFGroup", UpdateStatusBars)
hooksecurefunc(UF, "CreateAndUpdateHeaderGroup", UpdateStatusBars)
hooksecurefunc(UF, "ForceShow", UpdateStatusBars)