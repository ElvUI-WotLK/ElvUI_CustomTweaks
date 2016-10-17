local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule("NamePlates");
local CT = E:GetModule("CustomTweaks")
local isEnabled = E.private["nameplate"].enable and E.private["CustomTweaks"] and E.private["CustomTweaks"]["NamePlatesText"] and true or false

P["CustomTweaks"]["NamePlatesText"] = {
	["name"] = {
		["point"] = "TOP",
		["xOffset"] = 0,
		["yOffset"] = 12
	},
	["level"] = {
		["point"] = "RIGHT",
		["xOffset"] = 12,
		["yOffset"] = 1
	}
};

local anchorValues = {
	["TOP"] = "TOP",
	["BOTTOM"] = "BOTTOM",
	["CENTER"] = "CENTER",
	["LEFT"] = "LEFT",
	["RIGHT"] = "RIGHT"
};

local function ConfigTable()
	E.Options.args.CustomTweaks.args.NamePlate.args.options.args.NamePlatesText = {
		type = "group",
		name = "NamePlatesText",
		args = {
			nameGroup = {
				order = 1,
				type = "group",
				name = L["Name Text"],
				guiInline = true,
				get = function(info) return E.db.CustomTweaks.NamePlatesText.name[info[#info]]; end,
				set = function(info, value) E.db.CustomTweaks.NamePlatesText.name[info[#info]] = value; NP:UpdateAllPlates(); end,
				args = {
					point = {
						order = 1,
						type = "select",
						name = L["Anchor Point"],
						values = anchorValues
					},
					xOffset = {
						order = 2,
						type = "range",
						name = L["X-Offset"],
						min = -50, max = 50, step = 1
					},
					yOffset = {
						order = 3,
						type = "range",
						name = L["Y-Offset"],
						min = -50, max = 50, step = 1
					}
				}
			},
			levelGroup = {
				order = 2,
				type = "group",
				name = L["Level Text"],
				guiInline = true,
				get = function(info) return E.db.CustomTweaks.NamePlatesText.level[info[#info]]; end,
				set = function(info, value) E.db.CustomTweaks.NamePlatesText.level[info[#info]] = value; NP:UpdateAllPlates(); end,
				args = {
					point = {
						order = 1,
						type = "select",
						name = L["Anchor Point"],
						values = anchorValues,
					},
					xOffset = {
						order = 2,
						type = "range",
						name = L["X-Offset"],
						min = -50, max = 50, step = 1,
					},
					yOffset = {
						order = 3,
						type = "range",
						name = L["Y-Offset"],
						min = -50, max = 50, step = 1
					}
				}
			}
		}
	}
end
CT.Configs["NamePlatesText"] = ConfigTable;
if(not isEnabled) then return; end

hooksecurefunc(NP, "ConfigureElement_Name", function(_, frame)
	local db = E.db.CustomTweaks.NamePlatesText.name;
	local name = frame.Name;
	name:ClearAllPoints();
	name:SetJustifyH("CENTER");
	name:SetPoint(db.point, frame.HealthBar, db.point, db.xOffset, db.yOffset);
end);

hooksecurefunc(NP, "ConfigureElement_Level", function(_, frame)
	local db = E.db.CustomTweaks.NamePlatesText.level;
	local level = frame.Level;
	level:ClearAllPoints();
	level:SetPoint(db.point, frame.HealthBar, db.point, db.xOffset, db.yOffset);
end);